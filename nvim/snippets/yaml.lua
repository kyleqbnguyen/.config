local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
  s("fmt", {
    t({
      "BasedOnStyle: LLVM",
      "",
      "AllowShortFunctionsOnASingleLine: Inline",
      "AllowShortIfStatementsOnASingleLine: AllIfsAndElse",
      "AllowShortBlocksOnASingleLine: Always",
      "",
      "DerivePointerAlignment: false",
      "PointerAlignment: Left",
      "ReferenceAlignment: Left",
      "",
      "AlignAfterOpenBracket: Align",
      "AlignTrailingComments: true",
      "",
      "SortIncludes: true",
      "IncludeBlocks: Regroup",
      "",
      "IndentAccessModifiers: false",
      "NamespaceIndentation: None",
    }),
  }),

  s("tidy", {
    t({
      "Checks: >-",
      "  clang-analyzer-*,",
      "  bugprone-*,",
      "  performance-*,",
      "  modernize-*,",
      "  readability-*,",
      "  cppcoreguidelines-*,",
      "  misc-*,",
      "  -hicpp-*,",
      "  -portability-*,",
      "  -readability-magic-numbers,",
      "  -cppcoreguidelines-avoid-magic-numbers,",
      "  -readability-identifier-naming,",
      "  readability-braces-around-statements",
      "",
      "WarningsAsErrors: ''",
      "HeaderFilterRegex: '.*'",
      "AnalyzeTemporaryDtors: false",
      "FormatStyle: file",
      "",
      "CheckOptions:",
      "  - key: modernize-use-nullptr.NullMacros",
      "    value: 'NULL'",
    }),
  }),
}
