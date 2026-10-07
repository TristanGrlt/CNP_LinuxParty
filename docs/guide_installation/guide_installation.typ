#import "/docs/template.typ": cnp_template, callout

#show: cnp_template.with(
  title: "Ceci n'est pas une procédure d'installation",
  subtitle: "Ce guide fait référence à l'événement organiser le 16 Octobre 2026 par les étudiants du master informatique de l'UFR Sciences et Techniques du Madrillet",
  authors: (
    "Repris de F. Nicart",
    "S. de - Backer Cuvelier"
  ),
  date:  datetime.today().display( "[day padding:zero]/[month padding:zero]/[year repr:full]")
)

= Accueil des participants
1. Déterminer les besoins du demandeur (dual boot/Linux seul, type de distribution Linux, outils particuliers);
2. orienter le demandeur vers un installateur spécialisé en fonction des cas, ex : installation de Linux seul...;
3. Déterminer l’ergonomie attendue par l’utilisateur.

#columns(2)[
  #figure(caption: "Ciannamon")[
    #image("assets/thumb_cinnamon.png")
  ]
  #colbreak()
  #figure(caption: "Xfce")[
    #image("assets/thumb_xfce.png")
  ]
]

4. *Vérifier que l’utilisateur a effectué une sauvegarde complète de ses données personnelles;*
5. *Faire signer la décharge avant de poursuivre*

= Points de controles
#callout(title: "INFO")[
  *Avant de procéder à l’installation, il convient de tester le bon fonctionnement de la machine en faisant fonctionner la distribution choisie en mode Live et en testant les points de contrôle ci-dessous.*
]

Pour démarrer en Live :

1. Choisir une clé USB contenant le type de distribution désiré.
2. Péférer une version 64 bits si la machine est compatible.
3. En 64 bits, prendre soin de choisir l’entrée UEFI dans le menu de boot de la machine (ex : UEFI USB device:Ubuntu). Attention, sur certaine machines, il peut être nécessaire de redémarrer pour voir cette entrée apparaître dans le menu
4. Si la machine ne démarre pas sur la clé, voir *@resolprob*.

Les fonctionnalités à tester sont :

1. Bon fonctionnement des raccourcis clavier : volume du son, luminosité, rétro éclairage du clavier;
2. Acélération graphique : si les performances graphiques sont faibles, il vaudra mieux considérer un bureau comme XUbuntu ou Mate plutôt que Ubuntu classique ou Gnome par exemple;
3. Connectivité Ethernet
4. Connectivité Wifi
5. Connectivité bluetooth
6. Visibilité de tous les disques
7. sibilité de tous les disques (sudo fdisk -l ou utiliser GParted 1) ; Attention ! Si le schéma de partition semble suspect (Par exemple une grande partition ”basic data partition” impossible à monter), il est possible que bitlocker et/ou Intel RST soient activés. Il faudra les désactiver avant de poursuivre. Pour désactiver bitlocker, voir @bitlocker Pour désactiver Intel RST, voir @rst
8. Vérifier la mise en veille et la sortie de veille. Utiliser le menu système pour cela (il est possible que le comportement par défaut de la touche de mise en veille et la détection de la fermeture du couvercle ne
soit pas configurée par défaut, c’est le cas sous XUbuntu). Vérifier qu’en sortie de veille, tout le reste
demeure fonctionnel.

#callout(title: "Avant de poursuivre")[* Déterminer avec l’utilisateur si les fonctions non-opérationnelles pourraient être un problème.*]

= Prcocédure d'installation
== Préparation de l'espace disque
#callout(title: "Prérequis")[
  *Nous devons libérer de la place sur le disque avant l’installation. Pour un usage confortable, il convient d’allouer au minimum 20 Go à Linux.*
]

Les opérations suivantes sont risquées et il peut être salvateur de conserver la configuration d’origine des
partitions. Pour cela taper la commande suivante :

#align(center)[
  ```sh
  sudo fdisk -l > /tmp/nom_utilisateur.txt
  ```
]
PUis sauvegarder le fichier crée par mail ou sur une clé USB.

Trois cas de figure pour libérer de l'espace :

=== Le système dispose d'espace non alloué
Si la taille de l’espace non alloué sur le disque dépasse la taille minimale pour installer Linux (20 Go), alors
il n’y a rien à faire.

=== Le système est scindé en deux partitions / disques
Beaucoup de nouveaux ordinateurs sont livrés avec deux partitions (ou parfois, et de manière équivalente,
deux disques) : l’une contenant Windows© et les données utilisateur, l’autre souvent inutilisée. Si l’utilisateur est d’accord pour utiliser la seconde partition, utiliser cette approche :

1. Démarrer l’ordinateur sous Windows©;
2. Localiser la lettre de lecteur (exemple : Z:) affectée à la seconde partition;
3. Ouvrir la partition et vérifier qu’aucune donnée ne s’y trouve. Le cas échéant, transférer les données sur la partition principale avec l’accord de l’utilisateur.
4. Depuis Windows©, supprimer la seconde partition : exécuter diskmgmt.msc, sélectionner la partition, puis supprimer.
\
#callout(title: "Attention")[
  *Important : laisser l’espace résultant vide. Ainsi, pour installer Linux, il suffira de choisir l’option Utiliser l’espace disponible.*
]
=== Redimensionner une partition
Soit il y a une seule partition (en dehors de celle de l’UEFI et de recovery), soit il y en a une autre mais
l’utilisateur souhaite la conserver. Il faudra dans ce cas réduire la taille d’une des partitions existantes pour
créer de l’espace libre sur le disque. De façon (très surprenante), notre expérience récente montre que les outils
de Windows© pour vérifier/modifier des systèmes de fichiers Windows© ne sont pas fiables. Nous préconisons
donc d’utiliser gparted à partir d’un Linux démarré sur une clé USB pour réaliser cette opération :

1. S’assurer que l’ordinateur fonctionne avec une alimentation secteur (pas sur batterie).
2. Démarrer l’ordinateur sous Windows© pour effectuer les opérations suivantes :
  1. Assurez-vous que bitlocker n’est pas activé (voir @bitlocker)
  2. Puis dans un terminal (presser meta+r, puis taper cmd) :
  #align(center)[
    ```sh shutdown -s -f -t 0```
  ]
  Cela arrêtera Windows© en nous assurant que celui-ci a complètement fermé son système de fichiers (une histoire de caches).
3. Démarrer Ubuntu en live.
4. Exécuter gparted avec les droits administrateur : ```sh sudo gparted```
5. Vérifier le nombre de disques détectés (l’un d’eux correspond à la clé usb) et sélectionner celui contenant la partition à redimensionner.
6. Sélectionner la partition à redimensionner, puis choisir Redimensionner/déplacer.
7. Réduire la taille de la partition jusqu’à ce le champs espace libre suivant indique la taille désirée :

#figure(caption: "Redimensionner une partition avec gparted")[
  #image("assets/gparted.png", width: 80%)
]

#callout(title: "Important")[
  *NE PAS déplacer la partition si ce n’est pas nécessaire. Pour cela, avant de cliquer sur ”appliquer”, pensez à bien vérifier qu’aucun espace libre n’a pas été ajouté avant (à gauche de) la partition retaillée. Cela peut arriver par accident avec un glisser-lâcher malencontreux sur la partition. Si cela arrive, annuler les modifications et recommencer (ne pas remettre en place manuellement). En effet, si la partition est déplacée, le déplacement pourra prendra plusieurs heures (quelque soit le taux d’occupation !) là ou un redimensionnement seul ne prendra que quelques minutes.*
]
À l’issue de la procédure, il doit y avoir suffisamment d’espace libre (non alloué) pour installer Ubuntu.

== Installation du système
1. S'ssurer que l’ordinateur est raccordé au secteur.
2. Redémarrer complètement le système en prenant soin de booter en UEFI si approprié.
3. Choisir *Installer* dans le menu de boot (grub) ou bien cliquer sur l’icône *Installer* sur le bureau une fois en live.
4. Si l’installateur détecte qu’Intel RST est actif sur la machine, il bloquera l’installation et il faudra suivre une procédure pour le désactiver pour poursuivre sans endommager Windows© (voir @rst).

Choix du type d'installation :

1. Si vous avez suivi l’étape de libération d’espace, il suffit de choisir Installer à coté de Windows (ou tout effacer si l’utilisateur ne souhaite pas garder l’ancien système). Attention ! Si l’installateur ne propose pas l’option Installer à coté de Windows, cela peut signifier que Windows© est installé en mode Legacy, même si la machine est configurée en UEFI. Ne pas continuer, car GRUB ne pourra pas dans ce cas détecter Windows©. Pour vérifier ceci :
  1. Inspecter la liste des partitions : l’absence d’une partition de petite taille marquée UEFI ET formatée en FAT confirme ceci. (Une petite partition formatée en NTFS peut être observée à la place.)
  2. Pour confirmer : redémarrer et configurer le BIOS en mode legacy. Si Windows© démarre, reprendre l’installation.
2. Si un schéma de partitionnement particulier est souhaité, choisir l’option Autre chose (uniquement en fonction de votre niveau de confiance. Appeler un responsable si nécessaire.)
3. Si l’utilisateur dispose de données sensibles et s’il fait une utilisation nomade de sa machine, lui proposer le chiffrement de son disque. Pour cela, cocher la case chiffrement de la partition système.

1. À l’étape de régionalisation, sauf besoin spécifique, choisir le clavier français - alternative. Vérifier le bon fonctionnement de la touche en dessous de Échappe (doit normalement produire le caractère ², le caractère ³ lorsque combinée avec la touche shift et le caractère ¹ lorsque combinée avec la touche AltGr).
2. Saisie des données utilisateur :
  1. ’assurer que l’utilisateur entre un mot de passe suffisamment robuste et qu’il n’y a aucun risque qu’il l’oublie.
  2. Dissuader d’utiliser l’ouverture de session automatique en cas d’utilisation nomade de la machine ou bien si elle est utilisée dans un lieu commun.
3. En cas de refus de démarrer sur Linux voir @repa

= Réglagle post-installation
== TODO execution du script
// TODO

= Résolutuon de problème <resolprob>
== Démarrage sur l'USB
Si la machine ne propose pas de démarrer sur la clé USB :
- vérifier que le BIOS est configuré pour booter sur l’USB ;
- vérifier l’”ordre de boot”, l’usb doit être placé avant le disque principal ;
- si la machine est configurée par défaut en Legacy ET qu’il y a déjà un système d’exploitation installé à conserver, ne pas changer ce réglage et installer Linux en Legacy ;
- si la machine est en UEFI, désactiver le secure boot, voir section 5.2 ;
- désactiver la fonction de démarrage rapide (Fast Boot chez Asus) ;
- s le BIOS est correctement configuré, brancher la clé sur un autre port USB (certaine machine n’accepte de démarrer que sur certains de leurs ports USB) ;
- en cas d’impossibilité à booter sur l’USB, graver un CD si la machine est équipée d’un lecteur.

== Configurer l'UEFI
=== Entrer dans l'UEFI / le BIOS
Pour entrer dans l’UEFI/BIOS, il faut en général appuyer sur une touche immédiatement après le démarrage.
La touche à utiliser est en général affichée sur le premier écran.
- ACER : F1 ou F2 (voire parfois CTRL+ALT+ESC).
- ASUS : ECHAP, F2, ou Suppr
- HP : Échap (HP ProBook G0 / G1) ou F10 ou F1 ou F2
- INTEL,TOSHIBA,LENOVO : F2
- SONY : F2 (parfois F3) ou bouton ASSIST. ALT + F2 pour le modèle VGN-NS21S (PCG-7151M).
- SAMSUNG : ALT+ F2.
Si la machine démarre directement sans offrir un moyen d’entrer dans l’UEFI, voir la section 5.3.
Une fois dans l’UEFI/BIOS :
- vérifier l’ordre de démarrage des périphériques (mettre usb en premier pour booter en live sur une clé
par exemple) ;
- désactiver Fast boot qui met en cache les premières étapes du démarrage et vous empêchera de voir les effets des modifications (par exemple démarrage de Windows au lieu de grub). Il est possible de la réactiver en fin d’installation si l’utilisateur est vraiment attaché au démarrage rapide de sa machine mais il pourrait y avoir des effets de bords dans certains cas par la suite (mise à jour de grub voire du noyau);
- désactiver le secure-boot. Vérifier que Windows© peut toujours démarrer avant de poursuivre avec Linux.

=== Désactiber le Secure-Boot
Le mode Secure Boot sert normalement à interdire le démarrage de la machine sur une autre cible que l’OS
installé (et en général avec une signature). Certaines machines ont cette fonctionnalité mal implémentée. Si vous parvenez à démarrer sur une clé USB sans désactiver le Secure Boot, alors il ne devrait pas être nécessaire de le désactiver pour l’installation. La plupart des machines offrent un menu permettant d’activer ou désactiver directement le Secure Boot. Dans les cas où l’option est gelée dans le menu, il faut définir un mot de passe administrateur pour la rendre disponible. ATTENTION : le mot de passe sera requis pour entrer dans l’UEFI par la suite.
== Impossible d'accéder à l'UEFI / le BIOS de l'ordiniateur
Certaines machines (les ACER avec Windows© 8 pré-installé) ne donnent pas accès facilement au BIOS/UEFI
de la machine. Dans ce cas, suivre la procédure :
1. appuyez la touche Windows + C ;
2. cliquez sur Paramètres ;
3. cliquez Modifier les Paramètres PC ;
4. sous Paramètres PC, sélectionnez Général ;
5. sous démarrage Avancé, cliquez Redémarrer maintenant. Le système redémarrera et affichera menu de
démarrage Windows© ;
6. dans le menu de démarrage, sélectionnez Dépannage ;
7. dans menu Dépannage, sélectionnez Options Avancées ;
8. dans le menu Options Avancées, sélectionnez Paramètres Firmware UEFI ;
9. cliquez Redémarrer pour redémarrer le système et accéder au (BIOS) UEFI.
Méthode alternative : empêcher Windows© de démarrer complètement trois fois de suite. Cela devrait
provoquer l’apparition d’une menu au démarrage suivant offrant un mode sans échec ainsi qu’une option pour
entrer dans l’UEFI.

== Réparation du processus de boot post-installation (Boot-Repair) <repa>
Si malgré les précautions suivantes :
- l’option fast-boot est désactivée dans le bios,
- le sécure boot est désactivé dans le bios,
- s’il s’agit d’un portable HP configuré en UEFI, consulter la section 5.5,
le système continue de ne démarrer que sous Windows©, ou bien ne démarre plus aucun système, il est possible
que le chargeur d’amorce ait été mal installé. Suivre la procédure suivante :
1. démarrer l’ordinateur sur le live CD (ou la liveUSB) Ubuntu ;
2. établir une connexion à internet ;
3. ouvrir un terminal et saisir les commandes suivantes : #align(center)[```sh sudo add-apt-repository ppa:yannubuntu/boot-repair```]
4. recharger la liste des paquets :
#align(center)[```sh sudo apt update```]
5. installer le paquet boot-repair : #align(center)[```sh sudo apt install boot-repair```]
6. lancer boot-Repair, utiliser la réparation recommandée et suivre scrupuleusement les instructions.

Plus de détails sont disponibles à cette adresse :
https://doc.ubuntu-fr.org/boot-repair

== Contournement du boot Windows© codé en dur dans l'UEFI
Certains portables HP (et peut-être Lenovo et d’autres marques) ont une implémentation modifiée de l’UEFI
pour ne booter que windows dans ce mode. Ainsi, si toutes les tentatives de réparation du boot post-installation
on échouée, essayez :
- démarrez Ubuntu en Live ;
- ouvrez la partition correspondant à /boot sur le disque de l’ordinateur (a priori la partition de petite
taille au début du disque ;
- placez-vous dans efi/boot ;
- recherchez le fichier bootx64.efi (il peut être nécessaire de descendre dans plus de répertoires) :
find -iname bootx64.efi
- renommez ce fichier pour en garder une copie ;
- localisez le fichier grubx64.efi et copiez le dans le répertoire en le renommant bootx64.efi ;
- redémarrez ;

#callout(title: "Note")[
  Note : sur certains portables HP, la cible recherchée par l’UEFI est :
  /EFI/HP/EFI/Microsoft/bootmfgw.efi (chemin à adapter éventuellement)
]

#show link: underline


== Désactiver bitlocker <bitlocker>
Pour désactiver le chiffrement de partition de Windows© :
1. démarrer sous Windows©,
2. se rendre dans panneau de configuration→Système et sécurité→Chiffrement de disque BitLocker
(ou rechercher Bitlocker dans le champs de recherche du menu),
3. s’il y a plusieurs partitions chiffrées, assurez-vous d’identifier correctement la lettre de lecteur (ex H:) de
celle que vous voulez modifier,
4. dans la section correspondant au lecteur en question, choisir Désactiver Bitlocker (Turn off Bitlocker)
et confirmer. Le déchiffrement du lecteur peut prendre un moment en fonction de la quantité de données,
5. une fois le déchiffrement terminé, redémarrer l’ordinateur à nouveau sous Windows© et se loger pour
vérifier que les données sont intactes et Windows© fonctionnel,
6. arrêter Windows© depuis un terminal (presser meta+r, puis taper cmd) avec la commande : #align(center)[
    ```sh shutdown -s -f -t 0```
  ]
7. poursuivre le processus d’installation.
*Source :* #link("https://discourse.ubuntu.com/t/ubuntu-installation-on-computers-running-windows-and-bitlocker-turned-on/15338")
== Désactiver Intel RST <rst>
La procédure officielle est disponible ici : #link("https://help.ubuntu.com/rst/").
Il ne faut pas désactiver Intel RST dans le bios sans suivre ces étapes sous peine de rendre Windows© non
fonctionnel ! Nous devons au préalable forcer Windows© à utiliser le mode AHCI
1. Démarrer l’ordinateur sous Windows©,
2. Lancer l’éditeur de registre (regedit) et se rendre au ”dossier”
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\iaStorV\
et s’assurer que la clé Start est à la valeur 0 (noter l’ancienne valeur en cas de changement).
3. Se rendre dans le sous-dossier StartOverride et s’assurer que la clé 0 est à la valeur 0 (noter l’ancienne valeur en cas de changement).
4. Répéter ces deux opérations sous le dossier HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\storahci\
5. Redémarrer l’ordinateur et entrer dans le bios.
6. Désactiver Intel RST et sauvegarder les réglages.
7. Redémarrer l’ordinateur sous Windows© et vérifier que le mode d’accès aux disques est bien AHCI à l’aide du gestionnaire de périphériques.
8. Arrêter Windows© depuis un terminal (presser meta+r, puis taper cmd) avec la commande : #align(center)[
    ```sh shutdown -s -f -t 0```
  ]
9. Poursuivre le processus d’installation.
Si vous obtenez une erreur INACCESSIBLE BOOT DEVICE sur un écran bleu au redémarrage de Windows©, la
procédure n’a pas été réalisée correctement. Il peut suffire de réactiver Intel RST dans le bios pour retrouver
Windows©. Dans le cas contraire, il faudra suivre une procédure manuelle de récupération décrite dans la
documentation officielle Ubuntu (#link("https://help.ubuntu.com/rst/")).
== Plantage de la machine dû à un disque NVME
Expérimenté sur un ACER Aspire 3 (A314) avec un NVME Western digital.
Le noyau se plaint que le contrôleur NVME est désactivé (down) et spécule une gestion d’énergie défaillante.

Il propose des paramètres à passer au noyau qui s’avèrent insuffisants pour corriger le problème.

En revanche, cette liste de paramètres permet d’amorcer le noyau avec succès sur un Acer A314 :
#align(center)[
  ```sh
  noeject noautomount acpiphp.disable=1 pcie_aspm=off nvme_core.default_ps_max_latency_us=14000
  ```
]