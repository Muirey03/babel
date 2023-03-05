import { parse } from "../lib/index.js";

function getParser(code) {
  return () => parse(code, { sourceType: "module" });
}

describe("large ternary syntax", function () {
  it("should parse", function () {
    expect(getParser(`let y = (1 ?@ 1:50 ? 0:51 ? 52);`)()).not.toBeNull();
  });
});
