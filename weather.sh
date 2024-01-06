#!/bin/bash



# Hazırlayan: Ahmet KORKMAZ 21360859072



# Bu betik bir Hava durumu uygulamasıdır.
# Kullanıcıdan alınan değere göre tüm şehirlerin veya sadece istenen şehrin hava durumu bilgilerini OpenWearherMap api kullanılarak ekrana yazdırılır.
# Ekrana yazdırılan bilgiler aynı zamanda hava_durunu.txt dosyasına eklenir.

echo "***hava durumu uygulamasina hosgeldiniz***"
echo "1 - tum sehirler icin 1'e basin"
echo "2 - merak ettiginiz sehri girmek icin 2'ye basin"
read secenek

API_KEY="88a3ec8910389e9d3ae38ad50e8fff2e" # API_KEY en son çalışır durumdaydı

# Fonksiyonlar
tumSehir(){
COUNTRY_CODE="TR" # Türkiye için ülke kodu
# Şehirlerin bulunduğu listeyi indir
CITIES=$(curl -s "http://bulk.openweathermap.org/sample/city.list.json.gz" | zcat | jq '.[] | select(.country == "'${COUNTRY_CODE}'") | .name' | tr -d '"' | sort)

for CITY in $CITIES; do # Döngü
    # OpenWeatherMap API kullanarak hava durumu ve sıcaklık bilgisini al
    weather=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${CITY},${COUNTRY_CODE}&appid=${API_KEY}&units=metric")
    temperature=$(echo "$weather" | jq '.main.temp')
    # Gerekli bilgileri çıkar
    description=$(echo "$weather" | jq '.weather[0].description')
    # Yazdır
    echo "->Şehir: $CITY - Sıcaklık: $temperature°C - Hava Durumu: $description"
    date
done
}

tekSehir(){
    echo "lutfen sehir giriniz"
    read CITY # Kullanıcıdan şehir bilgisini oku
    # OpenWeatherMap API kullanarak hava durumu bilgisini al
    weather=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=metric")
    # Gerekli bilgileri çıkar
    description=$(echo "$weather" | grep -o '"description":"[^"]*' | cut -d "\"" -f 4)
    temperature=$(echo "$weather" | grep -o '"temp":[0-9.]*' | cut -d ":" -f 2)
    # Yazdır
    echo "$CITY  Hava Durumu: $description"
    echo "$CITY     Sıcaklık: $temperature°C"
    date
}


if [ "$secenek" = "1" ]; then
    tumSehir | tee -a hava_durumu.txt # tumSehir fonksiyonunu cağır ve çıktıları txt dosyasına aktar.
else
    tekSehir | tee -a hava_durumu.txt # Aynı işlemi yapar
fi
