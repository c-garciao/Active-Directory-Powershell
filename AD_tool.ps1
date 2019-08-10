#Carlos Garcia Oliva
#2ASIR 2018/2019
$nombre_dominio = $env:USERDNSDOMAIN
#Comprobamos si es nula la variable(!<nombre_variable>) que contiene el nombre del dominio. De sear así, saltara el error
if (!$nombre_dominio){
  Write-Host -BackgroundColor:Red "Error. No esta en ningun dominio"
  pause
}else{
  $n_t=$nombre_dominio.split('.')
  $d1=$n_t[0]
  $d2=$n_t[1]
  #Guardamos el nombre del dominio por SEPARADO (con la orden split y el delimitador del punto '.'). Luego volcamos en 2 variables la posicion 1 y 2 del array, ya que nos seran necesarias mas adelante
    #En caso de opcion incorrecta, hay una pausa. Si se desea SALIR de una OPCION, dejar un CAMPO EN BLANCO y CONFIRMAR  (despues del error, presionar enter y automaticamente volvera al menu)
  #------------------------------------------Funciones Usuarios------------------------------------------#
function lista_usuarios(){
    Clear-Host
    Write-Host "Listado de usuarios:"
    Get-ADUser -Filter * | Select-Object -Property SamAccountName | Format-Wide #Listamos el SamAccountName de los usuarios (el nommbre de INICIO de SESION, sin espacios)
}
function alta_usuario(){
    Clear-Host
    $nombre = Read-Host "Nombre del usuario"
    $pass= Read-Host "Contrasenia del usuario $nombre" -AsSecureString
    if(!$nombre -or $pass.Length -eq 0){
      Write-Host "Error.No pueden ser nulo ninguno de los campos" -BackgroundColor:red
    }else{
      New-ADUser -SamAccountName "$nombre" -Name "$nombre" -AccountPassword $pass -PasswordNeverExpires 1 -Enabled 1 -Confirm #1 y 0 se corresponden a $true y $false
  }
}
function baja_usuario(){
    Clear-Host
    lista_usuarios
    $nombre = Read-Host "Escriba el nombre del usuario a BORRAR"
    if(!$nombre){
      Write-Host "Error.Debe escribir un nombre de usuario"
    } else {
      Remove-ADUser -Identity "$nombre" -Confirm
  }
}
function cambia_contrasenia(){
  Clear-Host
  lista_usuarios
  $usuario = Read-Host "Escriba el nombre del usuario a cambiar la contrasenia"
  #$old_pass=Read-Host "Escriba la contrasenia ACTUAL del usuario" -AsSecureString
  $new_pass=Read-Host "Escriba la NUEVA contrasenia del usuario" -AsSecureString
  #Set-ADAccountPassword -Identity $usuario -OldPassword $old_pass -NewPassword $new_pass
  if(!$usuario -or $new_pass.Length -eq 0){
    Write-Host "Error.Debe introducir ambos datos"
  } else {
    Set-ADAccountPassword -Identity $usuario -Reset -NewPassword $new_pass
  }
}
#------------------------------------------Funciones Grupos------------------------------------------#
function lista_grupos(){
  Clear-Host
  Write-Host "Listado de grupos"
  Get-ADGroup -Filter * | Select-Object -Property Name | Format-Wide #Format Wide nos permite visualizar mejor los datos
}
#El atributo -Confirm, pide confirmacion antes de ejecutar el comando/la orden
function alta_grupo(){
  Clear-Host
  $nombre = Read-Host "Escriba el nombre del nuevo grupo"
  if(!$nombre){
    Write-Host "Error.Debe escribir un nombre para el grupo"
  } else {
    New-ADGroup  -DisplayName "$nombre" -Name "$nombre" -Confirm -GroupScope 1 #GroupScope: 1:Solo visible en su dominio, 2:visibilad en todo el bosque pero solo puede contener cuentas del mismo dominio 3:visibilad en todo el bosque y pueden contener cuentas de Todo el bosque
  }
}
function baja_grupo(){
  Clear-Host
  lista_grupos #Listamos los grupos del dominio y pedimos que escoja uno para borrar
  $nombre = Read-Host "Escriba el nombre del grupo a BORRAR"
  if(!$nombre){
    Write-Host "Error. No ha escrito ningun nombre"
  } else {
    Remove-ADGroup -Identity $nombre -Confirm
  }
}
function lista_usus_grupos($grupo){
  #Get-ADGroupMember -Identity $grupo | Select-Object -Property Name| Format-Wide
  Get-ADGroupMember -Identity $grupo | Select-Object  SamAccountName | Format-Wide
}
function usu_grupo(){
  Clear-Host
  lista_usuarios
  $usuario = Read-Host "Escoja un usuario."
  lista_grupos
  $grupo = Read-Host "Escoja un grupo"
  if(!$usuario -or !$grupo){
    Write-Host "Error.Debe completar ambos campos"
  } else {
    Add-ADGroupMember -Identity $grupo -Members $usuario -Confirm
  }
}
function r_usu_grupo(){
  Clear-Host
  lista_grupos
  $grupo = Read-Host "Escoja un grupo para ver sus miembros"
  if (!$grupo){
    Write-Host "Error.Debe completar el campo"
  }else{
  $temp = Get-ADGroupMember -Identity $grupo | Select-Object -Property Name| Format-Wide
  if ($temp -eq $null){
    Write-Host "El grupo $grupo no contiene ningun usuario" -BackgroundColor:Yellow -Foregroundcolor:Black #Comprobamos que haya usuarios en el grupo comparando la salida del omando con nulo, que es una variable boolena (si es true, significa que no hay usuarios en el grupo. Vuelve a llamar a la funcion para solicitar de nuevo un grupo)
    pause
    r_usu_grupo
  }else{
    lista_usus_grupos $grupo
    $usuario = Read-Host "Escoja un usuario a BORRAR del GRUPO $grupo" #`nPara varios, escribirlos separados por comas"

          if(!$usuario -or !$grupo){
            Write-Host "Error.Debe completar ambos campos"
          } else {
            Remove-ADGroupMember -Identity "$grupo" -Members $usuario
          }
      }
    }
  }
}
#------------------------------------------Funciones Ud. Organizativas------------------------------------------#
function lista_uo(){
  Clear-Host
  Write-Host "Listado de Unidades Organizativas:"
  Get-ADOrganizationalUnit -Filter * | Select-Object -Property Name | Format-Wide
}
function alta_uo(){
  Clear-Host
  $nombre = Read-Host "Escriba el nombre de la nueva ud. Organizativa"
  if(!$nombre){
    Write-Host "Error.Debe escribir un nombre para la UO"
  } else {
    New-ADOrganizationalUnit -Name "$nombre" -DisplayName "$nombre" -Confirm
  }
}
function baja_uo(){
  Clear-Host
  lista_uo
  $nombre = Read-Host "Escriba el nombre de la ud. Organizativa a BORRAR (es RECURSIVA y no se pueden recuperar los datos).`nPreviamente se eliminara la proteccion "
  if(!$nombre){
    Write-Host "Error.Debe escribir un nombre de UO"
  } else {
    Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$nombre*"}  | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Recursive -Confirm
    #Get-ADOrganizationalUnit -Identity 'OU=$nombre,DC=carlosg,DC=local' | Set-ADObject -ProtectedFromAccidentalDeletion:$false
   #Remove-ADOrganizationalUnit -Recursive -Confirm
  }
}
function aniade_usu_uo(){
  Clear-host
  lista_usuarios
  Write-Host "Escoja un usuario" -BackgroundColor:Cyan
  $usuario=Read-Host #-BackgroundColor:Cyan
  lista_uo
  Write-Host "Escoja una UO" -BackgroundColor:DarkMagenta
  $uo=Read-Host
  if(!$usuario -or !$uo){
    Write-Host "Error. Debe rellenar ambos campos"
  }else{
    Get-ADUser -Filter * | Where-Object {$_.name -like "*$usuario*"} -OutVariable usu #Filtramos la seleccion para que se lo mas exacta posible (debe devolver 1 solo elemento)
    Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo*"} -OutVariable path_usu
    Move-ADObject -Identity $usu.ObjectGUID -TargetPath $path_usu.ObjectGUID -Confirm
  }
}
function usu_uo($nombre_uo){
    Clear-Host
    $uoGuid = (Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -like "*$nombre_uo*"} | Select-Object -Expand ObjectGUID).toString() #Volcamos el resultado en una variable de tipo STRING(de lo contrario, la volcaria asi: @{GUID=<guid>} )
    $ruta=(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.ObjectGUID -eq "$uoGuid"} | Select-Object -Expand DistinguishedName).toString()
    Get-ADUser -Filter * -SearchBase $ruta | Format-Wide #Obtenemos el identificador de la UO para listar los usuarios
}
function borra_usu_uo(){
  Clear-host
  lista_uo
  Write-Host "Escoja una UO"
  $uo=Read-Host
  if(!$uo){
    Write-Host "Error. Debe escribir el nombre de una UO"
  }else{
      $uoGuid = (Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -like "*$uo*"} | Select-Object -Expand ObjectGUID).toString()
      $ruta=(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.ObjectGUID -eq "$uoGuid"} | Select-Object -Expand DistinguishedName).toString()
      $temp = Get-ADUser -Filter * -SearchBase "$ruta" | Format-Wide
      if($temp -eq $null){
        Write-Host "La UO $uo no contiene ningun usuario" -BackgroundColor:Yellow -Foregroundcolor:Black
        pause
        borra_usu_uo
      }else{
        usu_uo $uo
        Write-Host "Escoja un usuario de la Ud. Org.: $ou `nEl usuario se movera a la UO por DEFECTO: `"Users`"" #` nos permite representar los caracteresque van a continuacion (caracter de escape)
        $usuario=Read-Host #-BackgroundColor:Cyan
        if(!$usuario){
          Write-Host "Error. Debe rellenar el nombre"
        }else{
          Get-ADUser -Filter * | Where-Object {$_.name -like "*$usuario*"} -OutVariable usu #Con -OutVariable, guardammos el resultado del comando en una VARIABLE
          Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo*"} -OutVariable path_usu
          Move-ADObject -Identity $usu.ObjectGUID -TargetPath "CN=Users,DC=$d1,DC=$d2" -Confirm #Moveremos a los usuarios a Users (creada por defecto al promocionar a controlador de dominio)
    }
  }
  }
}
function grupo_uo($nombre_uo){
  Clear-Host
  $uoGuid = (Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -like "*$nombre_uo*"} | Select-Object -Expand ObjectGUID).toString()
  $ruta=(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.ObjectGUID -eq "$uoGuid"} | Select-Object -Expand DistinguishedName).toString()
  Get-ADGroup -Filter * -SearchBase $ruta | Format-Wide
}
function aniade_grupo_uo(){
  Clear-host
  lista_grupos
  Write-Host "Escoja un grupo"
  $grupo=Read-Host #-BackgroundColor:Cyan
  lista_uo
  Write-Host "Escoja una UO" -BackgroundColor:DarkMagenta
  $uo=Read-Host
  if(!$grupo -or !$uo){
    Write-Host "Error. Debe rellenar ambos campos"
  }else{
    Get-ADGroup -Filter * | Where-Object {$_.name -like "*$grupo*"} -OutVariable gru
    Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo*"} -OutVariable path_usu
    Move-ADObject -Identity $gru.ObjectGUID -TargetPath $path_usu.ObjectGUID -Confirm #El GUID es un identificador UNICO, lo tienen todos los OBJETOS
  }
}
function borra_grupo_uo(){
  Clear-host
  lista_uo
  Write-Host "Escoja una UO"
  $uo=Read-Host
  if(!$uo){
    Write-Host "Error. Debe escribir el nombre de una UO"
  }else{
    $uoGuid = (Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -like "*$uo*"} | Select-Object -Expand ObjectGUID).toString()
    $ruta=(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.ObjectGUID -eq "$uoGuid"} | Select-Object -Expand DistinguishedName).toString()
    $temp = Get-ADGroup -Filter * -SearchBase $ruta | Format-Wide
    if ($temp -eq $null){
      Write-Host "La UO $uo no contiene ningun grupo" -BackgroundColor:Yellow -Foregroundcolor:Black
    }else{
    grupo_uo $uo #Llamamos a la funcion que nos devuelve los grupos de una UO especifica. Como parametro le pasamos el nombre de la OU
    Write-Host "Escoja un grupo de la Ud. Org.: $uo `nEl grupo se movera a la UO por DEFECTO: `"Users`""
    $grupo=Read-Host
      if(!$grupo){
        Write-Host "Error. Debe rellenar el nombre del grupo"
      }else{
        Get-ADGroup -Filter * | Where-Object {$_.name -like "*$grupo*"} -OutVariable gru
        #Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo*"} -OutVariable path_usu
        Move-ADObject -Identity $gru.ObjectGUID -TargetPath "CN=Users,DC=$d1,DC=$d2" -Confirm
      }
    }
  }
}
function mueve_uo(){
  Clear-host
  lista_uo
  Write-Host "Escoja la UO a mover"
  $uo=Read-Host
  Write-Host "Escoja la UO a la que se va a mover"
  $uo_mover=Read-Host
  if(!$uo -or !$uo_mover){
    Write-Host "Error. No puede dejar en blanco ninguno de los campos"
  }elseif($uo -eq $uo_mover){
    Write-Host "Error. No se puede mover la UO $uo a la Ud. Organizativa $uo_mover. Son la MISMA" -BackgroundColor:Yellow -ForegroundColor:Black #No podemos mover la UO a la misma ruta en la que esta
  }else{
    Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo*"} -OutVariable ud #Guardamos el resultado del comando en la variable "ud"
    Get-ADOrganizationalUnit -Filter * |  Where-Object {$_.Name -like "*$uo_mover*"} -OutVariable ud_mover
    $p1=$ud.ObjectGUID
    $p2=$ud_mover.ObjectGUID
    Set-ADObject -Identity $p1 -ProtectedFromAccidentalDeletion:$false #Eliminamos la proteccion del borrado (de lo contrario, dara error y no la borrara)
    Move-ADObject -Identity $p1 -TargetPath $p2 -Confirm
    $p1_n=$ud.ObjectGUID
    Set-ADObject -Identity $p1_n -ProtectedFromAccidentalDeletion:$true #Y la volvemos a activar ya en su nueva ruta
    #Set-ADObject -Identity "OU=$ud.,DC=$d1,DC=$d2" -ProtectedFromAccidentalDeletion:$false
    #Move-ADObject -Identity "OU=$uo,DC=$d1,DC=$d2" -TargetPath "OU=$uo_mover,DC=$d1,DC=$d2" -Confirm
    #Set-ADObject -Identity "OU=$uo,OU=$uo_mover,DC=$d1,DC=$d2" -ProtectedFromAccidentalDeletion:$true
  }
}
#------------------------------------------Funciones Carpetas------------------------------------------#
function compartir_carpetas(){
  Clear-host
  $ruta=Read-Host "Introduzca la ruta de la carpeta a compartir"
  if(!$ruta){
    Write-Host "Error. Debe introducir una ruta"
  }else{
    if((test-path $ruta) -eq $true){
      $nombre=Read-Host "Introduzca el nombre del recurso compartido"
      lista_usuarios
      $usuario=Read-Host "Introduzca el nombre del usuario con el que compartir el recurso"
      if(!$nombre -or !$usuario){
        Write-Host "Error. Ambos campos son necesarios"
      }else{
        New-SmbShare -Name $nombre -Path "$ruta" -FullAccess $nombre_dominio\$usuario #Por ej.: New-SmbShare -Name "recurso compartido" -Path C:\Logs -FullAccess contoso.local\Administrador,Marta,Laura. Solo he contemplado compartir la carpeta para 1 usuario (para varios, se escriben separados por comas, pero da problemas Read-Host para ello)
      }
    }else {
      Write-Host "Error. No existe la ruta `"$ruta`""
    }
  }
}
function baja_carpetas(){
  Clear-host
  listar_carpetas
  $nombre=Read-Host "Escoja el nombre de una carpeta para dejar de compartirla"
  if(!$nombre){
      Write-Host "Error. Debe completar el campo"
    }else{
      Remove-SmbShare -Name $nombre -Confirm
  }
}
function listar_carpetas(){
  Clear-host
  Write-Host "Listado de carpetas compartidas en $nombre_dominio"
  Get-SmbShare | Format-Table #Listamos las carpetas (en la primera ejecucion puede listarlas de forma distinta)
}
#------------------------------------------FIN DE FUNCIONES------------------------------------------#
#Menu que vuelve a preguntar opciones al usuario hasta que este selecciona salir
while ($true){
Clear-Host
Write-Host "1. Usuarios"
Write-Host "2. Grupos"
Write-Host "3. Uds Organizativas"
Write-Host "4. Carpetas Compartidas"
Write-Host "5. Salir"
$opc = Read-Host "Escriba una opcion"
 switch ($opc) {
    1 {
      Clear-Host
      Write-Host "A.Alta Usuario"
      Write-Host "B.Baja Usuario"
      Write-Host "C.Listado Usuarios"
      Write-Host "D.Cambiar Contrasenia"
      Write-Host "E.Aniadir Usuario Ud Org"
      Write-Host "F.Borrar Usuario Ud Org"
      $opc_usu= Read-Host "Seleccione una opcion"
      #Estas opciones llaman a las funciones definidas en la cabecera de este script (se pueden volcar en otro fichero e importarlas: . <ruta_funciones>)
      if ($opc_usu -eq "A" -or $opc_usu -eq "a"){
          alta_usuario
          pause
      }elseif($opc_usu -eq "B" -or $opc_usu -eq "b"){
          baja_usuario
          pause
      }elseif($opc_usu -eq "C" -or $opc_usu -eq "c"){
          lista_usuarios
          pause
      }elseif($opc_usu -eq "D" -or $opc_usu -eq "d"){
          cambia_contrasenia
          pause
      }elseif($opc_usu -eq "E" -or $opc_usu -eq "e"){
          aniade_usu_uo
          pause
      }elseif($opc_usu -eq "F" -or $opc_usu -eq "f"){
          borra_usu_uo
          pause
      }else{
        Write-Host "Error. Opcion no valida"
        pause
      }
    } 2 {
      Clear-Host
      Write-Host "A.Alta Grupo"
      Write-Host "B.Baja Grupo"
      Write-Host "C.Listado Grupo"
      Write-Host "D.Aniadir usuario a grupo"
      Write-Host "E.Borrar usuario de grupo"
      Write-Host "F.Aniadir Grupo Ud Org"
      Write-Host "G.Borrar Grupo Ud Org"
      $opc_grupo= Read-Host "Seleccione una opcion"
      if ($opc_grupo -eq "A" -or $opc_grupo -eq "a"){
        alta_grupo
        pause
      }elseif($opc_grupo -eq "B" -or $opc_grupo -eq "b"){
            baja_grupo
            pause
      }elseif($opc_grupo -eq "C" -or $opc_grupo -eq "c"){
            lista_grupos
            pause
      }elseif($opc_grupo -eq "D" -or $opc_grupo -eq "d"){
            usu_grupo
            pause
      }elseif($opc_grupo -eq "E" -or $opc_grupo -eq "e"){
            r_usu_grupo
            pause
      }elseif($opc_grupo -eq "F" -or $opc_grupo -eq "f"){
            aniade_grupo_uo
            pause
      }elseif($opc_grupo -eq "G" -or $opc_grupo -eq "g"){
            borra_grupo_uo
            pause
      }else{
        Write-Host "Error. Opcion no valida"
        pause
      }
    } 3 {
      Clear-Host
      Write-Host "A.Alta Ud. Organizativa"
      Write-Host "B.Baja Ud. Organizativa"
      Write-Host "C.Listado Ud. Organizativa"
      Write-Host "D.Mover Ud. Organizativa"
      $opc_uo = Read-Host "Seleccione una opcion"
      if ($opc_uo -eq "A" -or $opc_uo -eq "a"){
        alta_uo
        pause
      }elseif($opc_uo -eq "B" -or $opc_uo -eq "b"){
            baja_uo
            pause
      }elseif($opc_uo -eq "C" -or $opc_uo -eq "c"){
            lista_uo
            pause
      }elseif($opc_uo -eq "D" -or $opc_uo -eq "d"){
            mueve_uo
            pause
      }else{
        Write-Host "Error. Opcion no valida"
        pause
      }
    } 4 {
      Clear-host
      Write-Host "A.Crear Carpeta compartida"
      Write-Host "B.Borrar Carpeta compartida"
      Write-Host "C.Listar Carpeta compartida"
      $opc_carpetas = Read-Host "Seleccione una opcion"
        if ($opc_carpetas -eq "A" -or $opc_carpetas -eq "a"){
          compartir_carpetas
          pause
        }elseif($opc_carpetas -eq "B" -or $opc_carpetas -eq "b"){
          baja_carpetas
          pause
        }elseif($opc_carpetas -eq "C" -or $opc_carpetas -eq "c"){
          listar_carpetas
          pause
        }else{
          Write-Host "Error. Opcion no valida"
          pause
        }
    } 5 {
      Clear-Host
     exit
    }
    default {
      Write-Host "Error. Opcion no reconocida"
      pause
    }
  }
}
