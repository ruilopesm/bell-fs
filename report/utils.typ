#let todo = text.with(fill: red)
#let done = text(fill: green)[Feito]

#let top-secret = table.cell(
  fill: red.lighten(60%),
)[Top-Secret]

#let secret = table.cell(
  fill: orange.lighten(60%),
)[Secret]

#let classified = table.cell(
  fill: green.lighten(60%),
)[Classified]

#let unclassified = table.cell(
  fill: aqua.lighten(60%),
)[Unclassified]

#let strong = table.cell(
  fill: orange.lighten(60%),
)[Strong]

#let medium = table.cell(
  fill: green.lighten(60%),
)[Medium]

#let weak = table.cell(
  fill: aqua.lighten(60%),
)[Weak]

#let braga = table.cell(
  fill: green.lighten(60%),
)[Braga]

#let porto = table.cell(
  fill: aqua.lighten(60%),
)[Porto]

#let lisboa = table.cell(
  fill: orange.lighten(60%),
)[Lisboa]

#let denied = table.cell(
  fill: red.lighten(60%),
)[Sem ficheiros]

#let code_block(
  code: []
) = block(
    fill: luma(240),
    inset: 1pt,
    radius: 4pt,
    stroke: 1pt,
    width: 100%,
    code,
)

#let code_grid(
  code1: [],
  code2: []
) = grid(
    columns: 2,
    gutter: 5mm,
    code1,
    code2,
)

#let image_block(
  imagem: image,
  caption: []
) = figure(
    block(
      inset: 2pt,
      radius: 5pt,
      stroke: 1pt,
      imagem
    ),
    caption: caption,
)

#let image_block_small(
  imagem: image,
  caption: []
) = figure(
    block(
      inset: 0.5pt,
      radius: 2pt,
      stroke: 1pt,
      imagem
    ),
    caption: caption,
)
