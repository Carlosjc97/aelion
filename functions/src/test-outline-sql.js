const test = require("node:test");
const assert = require("node:assert/strict");
const http = require("node:http");
const { outline } = require("../lib/index.js");

const fetch = (...args) => import("node-fetch").then(({ default: fetchFn }) => fetchFn(...args));

test("/outline returns SQL marketing template", async () => {
  const server = http.createServer((req, res) => {
    res.status = (code) => {
      res.statusCode = code;
      return res;
    };
    res.set = (field, value) => {
      res.setHeader(field, value);
      return res;
    };
    res.json = (payload) => {
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(payload));
      return res;
    };
    res.send = (payload) => {
      if (payload !== undefined && typeof payload === "object") {
        return res.json(payload);
      }
      res.end(payload ?? "");
      return res;
    };

    let rawBody = "";
    req.on("data", (chunk) => {
      rawBody += chunk;
    });
    req.on("end", async () => {
      try {
        req.body = rawBody ? JSON.parse(rawBody) : undefined;
      } catch {
        req.body = undefined;
      }
      req.ip = req.socket?.remoteAddress ?? "127.0.0.1";
      try {
        await outline(req, res);
      } catch (error) {
        res.status(500).json({
          error: "handler_failed",
          message: error instanceof Error ? error.message : String(error),
        });
      }
    });
  });

  await new Promise((resolve) => server.listen(0, resolve));
  const { port } = server.address();
  const url = `http://127.0.0.1:${port}/outline`;

  console.log("/outline POST ->", url);

  let response;
  try {
    response = await fetch(url, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "accept-language": "es-AR",
        "user-agent": "outline-sql-test",
      },
      body: JSON.stringify({
        topic: "SQL para Marketing",
        language: "es",
        depth: "medium",
        band: "intermediate",
      }),
    });
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }

  const responseBody = await response.json();
  console.log("/outline status:", response.status);
  console.log("/outline modules:", Array.isArray(responseBody.outline) ? responseBody.outline.length : "invalid");

  assert.equal(response.status, 200);
  assert.ok(Array.isArray(responseBody.outline));
  assert.equal(responseBody.outline.length, 6);
  assert.equal(responseBody.outline[0].locked, false);
  assert.ok(responseBody.outline.slice(1).every((module) => module.locked === true));
  assert.equal(responseBody.estimated_hours, 3.5);

  console.log("/outline estimated_hours:", responseBody.estimated_hours);
});
