# Projektplan
. 
## 1. Projektbeskrivning
En review page där användare kan registrera sig, logga in och skriva reviews. De kan även redigera och ta bort de reviews de själva har skrivit. Användare med admin-behörighet kan ta bort, men inte redigera, alla reviews. De kan även komma åt en user page, där de ser en lista med alla registrerade användare och skall ha möjligheten att ta bort en användare samt dess tillhörande reviews. Då varje review har tillhörande innehåll, titel, användare och genre relaterar reviews till titles, users och genres.
## 2. Vyer (visa bildskisser på dina sidor)
## 3. Databas med ER-diagram (Bild)
![ER](https://github.com/itggot-johan-scherman/storprojekt20/blob/master/ER-diagram.PNG?raw=true)
## 4. Arkitektur (Beskriv filer och mappar - vad gör/inehåller de?)
arkitektur:
code/n
  .yardoc - mapp autogenererad av yardoc
  db - mapp för databas
    database.db - databas
  doc - mapp autogenererad av yardoc
  public - tom mapp ämnad för CSS mm.
  views - Views i MVC, mapp för slim
    edit.slim - skriver upp sidan där man redigerar en recension
    error.slim - skriver upp sidan man skickas till om något blir fel
    index.slim - skriver upp startsidan där inloggning/registrering sker
    layout.slim - filen som berättar vilken typ av hemsida som ska genereras och hämtar data från aktuell slimfil
    reviews.slim - skriver upp sidan som visar alla recensioner efter inloggning
    users.slim - skriver upp sidan som visar alla användare för admin
  app.rb - applikationen, Console i MVC, innehåller alla routes och sessions
  gemfile - används för att aktivera yardoc
  gemfile.lock - autogenererad av gemfile
  model.rb - model, Model i MVC, innehåller alla funktioner som kallas på i app

