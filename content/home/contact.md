---
# An instance of the Contact widget.
widget: contact

# This file represents a page section.
headless: true

# Order that this section appears on the page.
weight: 130

title: Contact
subtitle:

# content:
#   # Automatically link email and phone or display as text?
#   autolink: true

#   # Contact details (edit or remove options as required)
#   email: 
#     - luca.pegoraro@wsl.ch
#     - jalison@ecos.au.dk
# design:
#   columns: '2'

### Cannot handle multiple emails with contact widget
### Use direct linking instead, append icon.
content:
  email: 

  contact_links:
    - icon: envelope
      icon_pack: fas
      name: Luca Pegoraro
      link: mailto:luca.pegoraro@wsl.ch

    - icon: envelope
      icon_pack: fas
      name: Jamie Alison
      link: mailto:jalison.ecos.au.dk
---
