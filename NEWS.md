
# swissValet (development version)

## New features

- RStudio addins that apply frequently used inspection functions to the
  current editor selection and execute them in the console: `xStrX()`,
  `xSummary()`, `xHead()`, `xDesc()`, `xAbstract()`, `xExample()`,
  `xPlot()`, `xUnclass()` and `xxlView()`.
- `flushToSource()` writes a selected object back into the document as
  reproducible source code; data frames are rendered as a readable
  `data.frame(...)` call rather than as `dput()` output.
- `selectVarDlg()` opens an interactive dialog for choosing elements,
  factor levels or data frame columns and returns the corresponding R
  expression, also copied to the clipboard.
- `toggleUnicodeAddin()`, `escapeUnicode()` and `unescapeUnicode()`
  convert between Unicode characters and escape sequences.
- `some()` returns a random subset of a vector, matrix or data frame,
  as a counterpart to `head()` and `tail()`.

## Acknowledgements

Parts of the code and documentation were reviewed with the help of large
language models (OpenAI Codex, Anthropic Claude). Every suggestion was
assessed, edited and verified by the maintainer, who remains solely
responsible for the content of this package.
