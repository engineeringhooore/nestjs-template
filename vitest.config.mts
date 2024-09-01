/// <reference types="vitest" />
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";
import swc from "unplugin-swc";

export default defineConfig({
  plugins: [
    tsconfigPaths(), // This is required to build the test files with SWC
    swc.vite({
      // Explicitly set the module type to avoid inheriting this value from a `.swcrc` config file
      module: { type: "es6" },
    }),
  ],
  test: {
    globals: true,
    restoreMocks: true,
    coverage: {
      provider: "v8",
      reporter: ["clover", "json", "lcov", "text", "json-summary"],
    },
  },
});
