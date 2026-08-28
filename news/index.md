# Changelog

## swissValet (development version)

### New features

- RStudio addins that apply frequently used inspection functions to the
  current editor selection and execute them in the console:
  [`xStrX()`](../reference/xStrX.md),
  [`xSummary()`](../reference/xSummary.md),
  [`xHead()`](../reference/xHead.md),
  [`xDesc()`](../reference/xDesc.md),
  [`xAbstract()`](../reference/xAbstract.md),
  [`xExample()`](../reference/xExample.md),
  [`xPlot()`](../reference/xPlot.md),
  [`xUnclass()`](../reference/xUnclass.md) and `xxlView()`.
- [`flushToSource()`](../reference/flushToSource.md) writes a selected
  object back into the document as reproducible source code; data frames
  are rendered as a readable `data.frame(...)` call rather than as
  [`dput()`](https://rdrr.io/r/base/dput.html) output.
- [`selectVarDlg()`](../reference/selectVarDlg.md) opens an interactive
  dialog for choosing elements, factor levels or data frame columns and
  returns the corresponding R expression, also copied to the clipboard.
- [`toggleUnicodeAddin()`](../reference/unicodeAddins.md),
  [`escapeUnicode()`](../reference/escapeUnicode.md) and
  [`unescapeUnicode()`](../reference/unescapeUnicode.md) convert between
  Unicode characters and escape sequences.
- [`some()`](../reference/some.md) returns a random subset of a vector,
  matrix or data frame, as a counterpart to
  [`head()`](https://rdrr.io/r/utils/head.html) and
  [`tail()`](https://rdrr.io/r/utils/head.html).

### Acknowledgements

Parts of the code and documentation were reviewed with the help of large
language models (OpenAI Codex, Anthropic Claude). Every suggestion was
assessed, edited and verified by the maintainer, who remains solely
responsible for the content of this package.
