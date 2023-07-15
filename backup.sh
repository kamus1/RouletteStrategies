#!/bin/bash

#----------colors---------------
greenColor="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"


#-------------functions---------

function ctrl_c(){
  echo -e "\n${redColor}[+] Saliendo...${endColor}\n"
  tput cnorm && exit 1
}
#ctrl+c 
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColor}[+]${endColor} Uso: ${purpleColor}$0${endColor}\n"
  echo -e "\t ${blueColor}-m${endColor} Dinero con el que se desea jugar"
  echo -e "\t ${blueColor}-t${endColor} Técnica a utilizar ${purpleColor}(martingala/inverseLabrouchere)${endColor}"
  echo -e "\t ${blueColor}-h${endColor} Panel de ayuda"
  exit 1
}

function martingala(){
  echo -e "\n${yellowColor}[+]${endColor} Dinero actual: ${yellowColor}$money\$${endColor}"
  echo -ne "${yellowColor}[+]${endColor} ¿Cuánto dinero quieres apostar? -> " && read initial_bet
  echo -ne "${yellowColor}[+]${endColor} ¿A qué deseas apostar continuamente (par/impar)? -> " && read par_impar

  echo -e "\n${yellowColor}[+]${endColor} Vamos a jugar con una cantidad inicial de ${yellowColor}$initial_bet\$${endColor} a la jugada ${yellowColor}$par_impar${endColor}"
  
  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas=""
  
  maximo_dinero_alcanzado=$money
  
  esJugadaInicial=true
  
  tput civis #ocultar el cursor
  while true; do
    if [ "$money" -gt $maximo_dinero_alcanzado ]; then
        maximo_dinero_alcanzado=$money
    fi

    money=$(($money-$initial_bet)) #restar dinero apostado
    #echo -e "\n${yellowColor}[+]${endColor} Acabas de apostar ${yellowColor}$initial_bet\$${endColor} y tienes ${yellowColor}$money\$${endColor}"
    random_number="$(($RANDOM % 37))"
    #echo -e "${yellowColor}[+]${endColor} Ha salido el número ${blueColor}$random_number${endColor}"
     

    #si se quedo sin dinero, y si no es la jugada inicial, (puede suceder el caso donde no es la jugada inicial pero llega exacatamente al 0)
    #(pero tambien pasa que en la primera jugada si apuesta todo su dinero se queda en 0, pero puede seguir jugando dependiendo si gana o pierde su apuesta)
    if [ "$money" -le 0 ] && [ $esJugadaInicial == false ]; then
      echo -e "\n${redColor}[!] Te has quedado sin dinero.${endColor}"

      #si el dinero es igual a 0 significa que se quedo sin dinero exactamente en 0 y no puedo jugar más
      if [ "$money" -eq "0" ]; then
        echo -e "${yellowColor}[+]${endColor} Han habido un total de ${yellowColor}$play_counter${endColor} jugadas."

      #pero si su dinero no quedó igual a 0, significa que programa apostó el doble aun sin tener el dinero suficiente, y perdió quedado con dinero negativo
      #esta jugada no es válida por lo tanto la descontamos
      else
        echo -e "${yellowColor}[+]${endColor} Han habido un total de ${yellowColor}$(($play_counter-1))${endColor} jugadas."
      fi


      cantidad_jugadasMalas=$(echo -n "$jugadas_malas" | grep -o ' ' | wc -l)
      echo -e "${yellowColor}[+]${endColor} Total jugadas malas consecutivas: ${redColor}$cantidad_jugadasMalas${endColor}, A continuación se representan las malas jugadas consecutivas que han salido:\n"
      echo -e "${blueColor}[ $jugadas_malas]${endColor}"

      echo -e "\n${yellowColor}[+]${endColor} Máximo dinero alcanzado ${greenColor}$maximo_dinero_alcanzado\$ ${endColor}"
      tput cnorm && exit 0
    fi

    if [ "$(($random_number % 2))" -eq 0 ]; then
      if [ "$random_number" -eq 0 ]; then
        #echo -e "${yellowColor}[+]${endColor} Ha salido el 0, por lo tanto ${redColor}perdemos${endColor}"
        initial_bet=$(($initial_bet*2))
        #echo -e "${yellowColor}[+]${endColor} Ahora mismo te quedas en ${yellowColor}$money\$ ${endColor}"
        jugadas_malas+="$random_number "

      elif [ "$par_impar" == "par" ]; then
        #echo -e "${yellowColor}[+]${endColor} El número que ha salido es par, ${greenColor}¡ganas!${endColor}"
        
        reward=$(($initial_bet*2))
        #echo -e "${yellowColor}[+]${endColor} Ganas un total de $reward\$"
        money=$(($money+$reward))
        #echo -e "${yellowColor}[+]${endColor} Tienes ${yellowColor}$money\$${endColor}"
        initial_bet=$backup_bet
        
        jugadas_malas=""

      else
        #echo -e "${yellowColor}[+]${endColor} El número que ha salido es par, ${redColor}¡pierdes!${endColor}"
        initial_bet=$(($initial_bet*2))
        #echo -e "${yellowColor}[+]${endColor} Ahora mismo te quedas en ${yellowColor}$money\$ ${endColor}"
        jugadas_malas+="$random_number "
      fi
    else
      if [ "$par_impar" == "impar" ]; then
        #echo -e "${yellowColor}[+]${endColor} El número que ha salido es impar, ${greenColor}¡ganas!${endColor}"
        reward=$(($initial_bet*2))
        #echo -e "${yellowColor}[+]${endColor} Ganas un total de $reward\$"
        money=$(($money+$reward))
        #echo -e "${yellowColor}[+]${endColor} Tienes ${yellowColor}$money\$ ${endColor}"
        initial_bet=$backup_bet

        jugadas_malas=""
      else
        #echo -e "${yellowColor}[+]${endColor} El número que ha salido es impar, ${redColor}¡pierdes!${endColor}"
        initial_bet=$(($initial_bet*2))
        #echo -e "${yellowColor}[+]${endColor} Ahora mismo te quedas en ${yellowColor}$money\$ ${endColor}"
        jugadas_malas+="$random_number "
      fi
    fi
    let play_counter+=1
    #sleep 0.1
    esJugadaInicial=false
  done 
  tput cnorm # recuperamos el cursor
}



function inverseLabrouchere(){
  echo -e "\n${yellowColor}[+]${endColor} Dinero actual: ${yellowColor}$money\$${endColor}"
  echo -ne "${yellowColor}[+]${endColor} ¿A qué deseas apostar continuamente (par/impar)? -> " && read par_impar

  declare -a my_sequence=(1 2 3 4)

  echo -e "\n[Comenzamos con la secuencia ${greenColor}[${my_sequence[@]}] ${endColor}"

  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))

  jugadas_totales=0

  tput civis
  #bucle
  while true; do
    let jugadas_totales+=1
    random_number=$(( $RANDOM % 37))
    money=$(($money - $bet))
    
    if [ ! "$money" -lt 0 ]; then
      echo -e "[+] Invertimos $bet$"
      echo -e "[+] Tenemos $money$" 
      
      echo -e "\n[+] Ha salido el numero ${blueColor}$random_number${endColor}"

      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ]; then
          echo -e "[+] El número es par, ${greenColor}¡ganas!${endColor}"
          reward=$(($bet*2))
          let money+=$reward
          echo -e "[+] Tienes $money$"

          my_sequence+=($bet)
          my_sequence=(${my_sequence[@]}) # por tema de las posiciones, por seguridad

          echo -e "[+] Nuestra nueva secuencia es ${greenColor}[${my_sequence[@]}]${endColor}"

          if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            echo -e "[!] Hemos perdido nuestra secuencia"
            my_sequence=(1 2 3 4)
            echo -e "[+] Restablecemos la secuencia a [${my_sequence[@]}]"
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          fi          

        elif [ "$((random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
          if [ "$((random_number % 2))" -eq 1 ]; then
            echo -e "[+] El número es impar, ${redColor}¡pierdes!${endColor}"
          else
            echo -e "[+] Ha salido el 0, ¡pierdes!"
          fi

          unset my_sequence[0]
          unset my_sequence[-1] 2>/dev/null
          
          my_sequence=(${my_sequence[@]}) # por tema de las posiciones

          echo -e "[+] La secuencia se nos queda de la siguiente forma:${blueColor} [${my_sequence[@]}]${endColor}"
          if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            echo -e "[!] Hemos perdido nuestra secuencia"
            my_sequence=(1 2 3 4)
            echo -e "[+] Restablecemos la secuencia a [${my_sequence[@]}]"
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          fi
        fi                                                                
      fi
    else
      echo -e "\n${redColor}[!] Te has quedado sin dinero.${endColor}"
      echo -e "[+] En total han habido ${yellowColor}$jugadas_totales${endColor} j ugadas totales"
      tput cnorm && exit 1 

    fi
  #sleep 1
  done
  tput cnorm
}



#---------code---------
while getopts "m:t:h" arg; do
  case $arg in 
    m) money="$OPTARG";;
    t) technique="$OPTARG";;
    h) helpPanel;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ]; then
    martingala
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere
  else
    echo -e "\n${redColor}[!] La técnica introducida no existe${endColor}"
    helpPanel
  fi

else
  helpPanel
fi
