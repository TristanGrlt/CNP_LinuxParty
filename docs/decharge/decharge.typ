#import "/docs/template.typ": cnp_template, callout

#show: cnp_template.with(
  title: "Ceci est une décharge de responsabilité",
  subtitle: "Cette décharge fait référence à l'événement organisé le 16 Octobre 2026 par les étudiants du master informatique de l'UFR Sciences et Techniques du Madrillet",
  authors: (
    "Repris de F. Nicart",
  ),
  date:  datetime.today().display( "[day padding:zero]/[month padding:zero]/[year repr:full]"),
  doOutline: false,
)

Je soussigné(e)

#table(
  columns: (auto, auto),
  stroke: none,
  [*Nom*], [*:*],
  [*Prénom*], [*:*],
  [*Courriel*], [*:*],
)



Déclare m’être présenté(e) ce jour à "Ceci n'est pas une Linux Party" du Madrillet organisée par les étudiants des Masters informatique de l’université de Rouen, et je reconnais avoir eu connaissance des recommandations suivantes :

- des risques, même minimes, existent lors de toute manipulation informatique qui pourraient entraîner des pertes ou des corruptions de données numériques, des dysfonctionnements matériels ou logiciels ;
- les organisateurs de "Ceci n'est pas une Linux Party" ne pourront être tenus responsables en cas d’altération de données, en cas de détérioration ou de vol de matériel

En outre, je déclare :

- avoir fait des sauvegardes de mes données,
- autoriser les organisateurs de "Ceci n'est pas une Linux Party" du Madrillet à procéder à l’installation d’un système d’exploitation libre sur mon ordinateur personnel, et à conﬁgurer les paramètres logiques en conséquence.

#v(2.5em)

#align(right)[
  *Signature :*
]
