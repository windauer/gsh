xquery version "3.1";

(: 
 pasted original list into oXygen, turned into XML with regex:
 
 find: (.*?)\n(.*?)\n\n
 replace with: <assignment><reviewer>$1</reviewer><territories>$2</territories></assignment>

 then cleaned up, pasted in here. 
:)
let $assignments := 
<assignments>
    <assignment>
        <reviewer>Ahlberg</reviewer>
        <territories>Algeria, Bahrain, Egypt, Iran, Iraq, Israel, Jordan, Kuwait, Lebanon,
            Sweden</territories>
    </assignment>
    <assignment>
        <reviewer>Barnum</reviewer>
        <territories>Greece, Holy See, Hungary, Iceland, Ireland, Italy, Kosovo, Latvia,
            Liechtenstein</territories>
    </assignment>
    <assignment>
        <reviewer>Berndt</reviewer>
        <territories>Antigua and Barbuda, Argentina, Aruba, The Bahamas, Barbados, Belize, Bermuda,
            Bolivia, Brazil, Zambia</territories>
    </assignment>
    <assignment>
        <reviewer>Burton</reviewer>
        <territories>Angola, Benin, Botswana, Burkina Faso, Burundi, Cameroon, Cabo Verde, Central
            African Republic, Chad, Turkey</territories>
    </assignment>
    <assignment>
        <reviewer>Charles</reviewer>
        <territories>Poland, Portugal, Romania, Russia, San Marino, Serbia, Slovakia, Slovenia,
            Spain</territories>
    </assignment>
    <assignment>
        <reviewer>Geyer</reviewer>
        <territories>Croatia, Cyprus, Czechia, Denmark, Estonia, Finland, France, Georgia,
            Germany</territories>
    </assignment>
    <assignment>
        <reviewer>Hawley</reviewer>
        <territories>Mongolia, Nauru, New Zealand, Palau, Papua New Guinea, Philippines, Samoa,
            Singapore, Solomon Islands, Uzbekistan </territories>
    </assignment>
    <assignment>
        <reviewer>Kolar</reviewer>
        <territories>The Gambia, Ghana, Guinea, Guinea-Bissau, Kenya, Lesotho, Liberia, Madagascar,
            Malawi, United Kingdom</territories>
    </assignment>
    <assignment>
        <reviewer>McCoyer</reviewer>
        <territories>Mali, Mauritania, Mauritius, Mozambique, Namibia, Niger, Nigeria, Rwanda, Sao
            Tome and Principe, Togo</territories>
    </assignment>
    <assignment>
        <reviewer>Munteanu</reviewer>
        <territories>Senegal, Seychelles, Sierra Leone, Somalia, South Africa, South Sudan, Sudan,
            Swaziland, Tanzania, Uganda</territories>
    </assignment>
    <assignment>
        <reviewer>Nickles</reviewer>
        <territories>Japan, Kiribati, North Korea, South Korea, Laos, Macau, Malaysia, Marshall
            Islands, Federated States of Micronesia, Turkmenistan</territories>
    </assignment>
    <assignment>
        <reviewer>Pitman</reviewer>
        <territories>Taiwan, Thailand, Timor-Leste, Tonga, Tuvalu, Vanuatu, Vietnam, Sri Lanka,
            Tajikistan</territories>
    </assignment>
    <assignment>
        <reviewer>Poster</reviewer>
        <territories>Ecuador, El Salvador, Grenada, Guatemala, Guyana, Haiti, Honduras, Jamaica,
            Mexico, Trinidad and Tobago</territories>
    </assignment>
    <assignment>
        <reviewer>Rasmussen</reviewer>
        <territories>Canada, Cayman Islands, Chile, Colombia, Costa Rica, Cuba, Curacao, Dominica,
            Dominican Republic, Zimbabwe</territories>
    </assignment>
    <assignment>
        <reviewer>Rotramel</reviewer>
        <territories>Lithuania, Luxembourg, Macedonia, Malta, Moldova, Monaco, Montenegro,
            Netherlands, Norway</territories>
    </assignment>
    <assignment>
        <reviewer>Rubin</reviewer>
        <territories>Australia, Brunei, Burma, Cambodia, China, Cook Islands, Fiji, Hong Kong,
            Indonesia, Venezuela</territories>
    </assignment>
    <assignment>
        <reviewer>Smith</reviewer>
        <territories>Nicaragua, Panama, Paraguay, Peru, Saint Kitts and Nevis, Saint Lucia, Sint
            Maarten, Saint Vincent and the Grenadines, Suriname, Uruguay</territories>
    </assignment>
    <assignment>
        <reviewer>Wieland</reviewer>
        <territories>Libya, Morocco, Oman, Qatar, Saudi Arabia, Syria, Tunisia, United Arab
            Emirates, Yemen, Switzerland</territories>
    </assignment>
    <assignment>
        <reviewer>Wilson</reviewer>
        <territories>Albania, Andorra, Armenia, Austria, Azerbaijan, Belarus, Belgium, Bosnia and
            Herzegovina, Bulgaria</territories>
    </assignment>
    <assignment>
        <reviewer>Woodroofe</reviewer>
        <territories>Congo-B, Congo-K, Comoros, Cote d’Ivoire, Djibouti, Equatorial Guinea, Eritrea,
            Ethiopia, Gabon, Ukraine</territories>
    </assignment>
    <assignment>
        <reviewer>Zierler</reviewer>
        <territories>Afghanistan, Bangladesh, Bhutan, India, Kazakhstan, Kyrgyzstan, Maldives,
            Nepal, Pakistan</territories>
    </assignment>
</assignments>

return
    element assignments {
        for $assignment in $assignments/*
        return
            element assignment {
                $assignment/reviewer,
                element territories {
                    for $t in tokenize($assignment/territories, ',\s+') ! normalize-space(.)
                    return
                        element territory {$t}
                }
            }
    }