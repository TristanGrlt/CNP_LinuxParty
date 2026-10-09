// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
#let offblack = rgb("#1C1C1C")
#let offwhite = rgb("#F4F4F0")
#let h1-color = rgb("#f9614f")
#let h2-color = rgb("#5ec3f5")
#let h3-color = rgb("#e459f5")

// -----------------------------------------------------------------------------
// Encarts
// -----------------------------------------------------------------------------
#let callout(title: "INFO", body) = block(
  width: 100%,
  stroke: (left: 4pt + offblack, rest: 1pt + offblack),
  fill: offwhite,
  inset: 1.2em,
  [
    #text(font: "Space Mono", weight: "bold", size: 10pt)[>\_ #title]
    #v(0.5em)
    #body
  ]
)

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------
#let cnp_template(
  title: "",
  subtitle: none,
  authors: [],
  date: "",
  doOutline: true,
  body
) = {
  set document(title: title, author: authors)

  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    numbering: "1",
    header: align(right)[
      #text(font: "Space Mono", size: 9pt, fill: rgb("#666666"))[
        Ceci n'est pas une Linux Party
      ]
    ],
    footer: [
      #line(length: 100%, stroke: 1pt + offblack)
      #v(2mm)
      #grid(
        columns: (1fr, 1fr),
        align(left)[#text(font: "Space Mono", size: 9pt)[#eval(title, mode: "markup")]],
        align(right)[#context text(font: "Space Mono", size: 9pt)[Page #counter(page).display()]]
      )
    ]
  )

  set text(
    font: "Space Grotesk",
    size: 10pt,
    fill: offblack,
    lang: "fr"
  )

  set heading(numbering: "1.1.1")
  show heading: it => {
    let box-color = if it.level == 1 { h1-color }
                    else if it.level == 2 { h2-color }
                    else { h3-color }

    let title-size = if it.level == 1 { 15pt }
                     else if it.level == 2 { 13pt }
                     else { 12pt }

    let title-text = if it.level == 1 { upper(it.body) } else { it.body }

    block(above: 1.5em, below: 1em)[
      #grid(
        columns: (auto, auto),
        gutter: 0.5em,
        align: horizon,
        
        if it.numbering != none {
          let number = counter(heading).display(it.numbering)
          box(
            fill: box-color, 
            inset: (x: 6pt, y: 4pt), 
            radius: 2pt,
            baseline: 0%,
            text(fill: white, weight: "bold", size: title-size * 0.9, number)
          )
        },
        
        text(size: title-size, weight: "bold", title-text)
      )
    ]
  }


  show raw.where(block: true): it => block(
    width: 100%,
    fill: offwhite,
    inset: 12pt,
    radius: 3pt,
    text(font: "Space Mono", size: 9.5pt, it)
  )

  show raw.where(block: false): it => box(
    fill: offwhite,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    text(font: "Space Mono", size: 10pt, it)
  )

  set list(marker: ([>\_], [-]))

  // -----------------------------------------------------------------------------
  // Title
  // -----------------------------------------------------------------------------
  align(center)[
    #block(
      width: 90%,
      inset: (x: 2em),
      {
        align(center)[
          #text(font: "Space Grotesk", size: 26pt, weight: "bold", upper(eval(title, mode: "markup"))) \
          #align(center)[
            #image("../visuels/logo/logo.png", width: 70pt)
          ]
          #if subtitle != none {
            v(0.5em)
            block(
              width: 100%,
              stroke: (y: 1.5pt + offblack),
              inset: (y: 1em),
              {
                text(font: "Space Mono", size: 12pt, weight: "bold", subtitle)
              }
            )
          }
        ]
      }
    )
    #v(0.5em)
    #grid(
      columns: (1fr, 1fr),
      align: left,
      [
        #for author in authors [
          #text(font: "Space Mono", size: 10pt)[#author]
          #linebreak()
        ]
      ],
      [
        #align(right)[
          #text(font: "Space Mono", size: 10pt)[#date]
        ]
      ],
    )

  ]

  v(2em)
  set heading(numbering: "1.")
  if doOutline {
    outline()
    pagebreak()
  }
  body
}
