// app/public/app.js — calls the API on the same CloudFront URL.
const form = document.getElementById("form");
const result = document.getElementById("result");

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  result.textContent = "Working...";
  const url = document.getElementById("url").value;
  try {
    const res = await fetch("/api/links", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url }),
    });
    const body = await res.json();
    if (!res.ok) throw new Error(body.error || res.statusText);
    const link = `${location.origin}/r/${body.code}`;
    result.innerHTML = "";
    const a = document.createElement("a");
    a.href = link;
    a.textContent = link;
    result.append("Short link: ", a);
  } catch (err) {
    result.textContent = `Error: ${err.message}`;
  }
});
