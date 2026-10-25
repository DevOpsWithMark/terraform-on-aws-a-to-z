// app/server.js
// URL Shortener API — Node.js + Express.
// Config comes from environment variables set by the ECS task.

import express from "express";
import { randomBytes } from "node:crypto";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const PORT = Number(process.env.PORT ?? 3000);
const TABLE = process.env.TABLE_NAME;
const ADMIN_TOKEN = process.env.ADMIN_TOKEN ?? "";

if (!TABLE) {
  console.error("TABLE_NAME is not set");
  process.exit(1);
}

const db = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const app = express();
app.use(express.json({ limit: "8kb" }));

// Short codes: 7 URL-safe characters.
const ALPHABET =
  "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
function newCode(length = 7) {
  const bytes = randomBytes(length);
  let code = "";
  for (const b of bytes) code += ALPHABET[b % ALPHABET.length];
  return code;
}

function isValidUrl(value) {
  try {
    const u = new URL(value);
    return u.protocol === "https:" || u.protocol === "http:";
  } catch {
    return false;
  }
}

// Health check for the load balancer.
app.get("/healthz", (_req, res) => {
  res.json({ status: "ok" });
});

// Create a short link.
app.post("/api/links", async (req, res) => {
  const url = req.body?.url;
  if (typeof url !== "string" || !isValidUrl(url)) {
    return res
      .status(400)
      .json({ error: 'Send {"url": "https://..."}' });
  }
  for (let attempt = 0; attempt < 3; attempt++) {
    const code = newCode();
    try {
      await db.send(new PutCommand({
        TableName: TABLE,
        Item: { code, url, createdAt: new Date().toISOString() },
        ConditionExpression: "attribute_not_exists(code)",
      }));
      // The browser adds its own origin (the CloudFront URL).
      return res.status(201).json({ code, url, path: `/r/${code}` });
    } catch (err) {
      if (err.name !== "ConditionalCheckFailedException") {
        console.error(err);
        return res.status(500).json({ error: "Could not save link" });
      }
    }
  }
  return res.status(503).json({ error: "Try again" });
});

// Look up a link without redirecting.
app.get("/api/links/:code", async (req, res) => {
  const out = await db.send(new GetCommand({
    TableName: TABLE,
    Key: { code: req.params.code },
  }));
  if (!out.Item) return res.status(404).json({ error: "Not found" });
  return res.json(out.Item);
});

// Delete a link (admin only).
app.delete("/api/links/:code", async (req, res) => {
  if (!ADMIN_TOKEN || req.get("x-admin-token") !== ADMIN_TOKEN) {
    return res.status(403).json({ error: "Forbidden" });
  }
  await db.send(new DeleteCommand({
    TableName: TABLE,
    Key: { code: req.params.code },
  }));
  return res.status(204).end();
});

// Follow a short link.
app.get("/r/:code", async (req, res) => {
  const out = await db.send(new GetCommand({
    TableName: TABLE,
    Key: { code: req.params.code },
  }));
  if (!out.Item) return res.status(404).send("Link not found");
  return res.redirect(301, out.Item.url);
});

app.listen(PORT, () => {
  console.log(`shortener listening on port ${PORT}`);
});
