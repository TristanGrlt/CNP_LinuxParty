#import "template.typ": cnp_template, callout

// Application du template avec les informations du document
#show: cnp_template.with(
  title: "Ceci n'est pas une procédure d'installation",
  subtitle: "Consectetur adipiscing elit sed do eiusmod",
  author: "Lorem Ipsum",
  date: "16 Octobre 2026"
)

= Lorem ipsum dolor sit

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#callout(title: "LOREM IPSUM : DOLOR SIT AMET")[
  *Duis aute irure dolor in reprehenderit* in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
]

== Consectetur adipiscing

Ut enim ad minim veniam, quis nostrud exercitation :
- Lorem ipsum dolor sit amet, consectetur adipiscing elit.
- Sed do eiusmod tempor incididunt ut labore et dolore.
- Ut enim ad minim veniam, quis nostrud exercitation ullamco.

= Sed do eiusmod tempor

== 1. Lorem ipsum dolor sit amet

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

```bash
# Lorem ipsum : dolor sit amet consectetur
lorem ipsum --dolor sit amet --consectetur adipiscing elit
```

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

== 2. Duis aute irure dolor

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

= Ut enim ad minim

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

```bash
lorem ipsum --dolor sit amet --consectetur adipiscing elit --sed do eiusmod
```

Consectetur adipiscing elit sed do eiusmod !

