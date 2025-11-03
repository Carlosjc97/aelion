import test, { afterEach } from "node:test";
import assert from "node:assert/strict";
import type { Request } from "express";
import type { Auth } from "firebase-admin/auth";
import {
  extractBearerToken,
  resolveUserId,
  resetAuthClientForTesting,
  setAuthClientForTesting,
} from "./index";

afterEach(() => {
  resetAuthClientForTesting();
});

function buildRequest(headers: Record<string, string>): Request {
  return {
    headers,
  } as unknown as Request;
}

test("extractBearerToken returns the token when Authorization header is valid", () => {
  const req = buildRequest({ authorization: "Bearer abc123" });
  assert.equal(extractBearerToken(req), "abc123");
});

test("extractBearerToken returns null when header is missing or malformed", () => {
  const noHeaderReq = buildRequest({});
  assert.equal(extractBearerToken(noHeaderReq), null);

  const malformedReq = buildRequest({ authorization: "Basic abc123" });
  assert.equal(extractBearerToken(malformedReq), null);
});

test("resolveUserId returns decoded uid when verifyIdToken succeeds", async () => {
  const req = buildRequest({ authorization: "Bearer valid-token" });
  const mockAuth = {
    verifyIdToken: async (token: string) => {
      assert.equal(token, "valid-token");
      return { uid: "user-42" };
    },
  } as unknown as Auth;

  setAuthClientForTesting(mockAuth);
  const userId = await resolveUserId(req);
  assert.equal(userId, "user-42");
});

test("resolveUserId falls back to anonymous when verification fails", async () => {
  const req = buildRequest({ authorization: "Bearer invalid-token" });
  const mockAuth = {
    verifyIdToken: async () => {
      throw new Error("bad token");
    },
  } as unknown as Auth;

  setAuthClientForTesting(mockAuth);
  const userId = await resolveUserId(req);
  assert.equal(userId, "anonymous");
});
