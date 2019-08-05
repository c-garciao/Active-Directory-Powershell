# Administración dominios AD mediante Powershell
Administración de servidores Active Directory mediante Powershell
## Getting Started

Proyecto creado con la finalidad de facilitar tareas a l@s adminitradores de sistemas.

### Requisitos

* Necesario Windows Server (2008 o superior)
```
winver
```

* Comprobar el estado de la ejecución de Scripts
```
Get-ExecutionPolicy
```
* Habilitar la ejecución de Scripts (en caso de que estuviese deshabilitada)
```
Set-ExecutionPolicy Unrestricted
```
### Instalación

Solo es necesario ejecutar el script (necesarios privilegios de administrador):

```
.\AD_Carlos_Garcia_Oliva.ps1
```
## Comprobación del entorno

El script comprobará automáticamente si se está ejecuntado desde un dominio AD. En caso contrario, no continuará con la ejecución del script.

Para comprender mejor la estructuración del mismo, es recomendable leer el fichero de [comentarios](./Comentarios.txt).
# Aviso importante

Está creado para funcionar con dominios de que forman un BOSQUE PRIMARIO (primer nivel), no para SUBDOMINIOS

## Built With

* [Atom](https://atom.io/) - Editor de texto utilizado
* [Powershell ISE](https://docs.microsoft.com/es-es/powershell/scripting/components/ise/introducing-the-windows-powershell-ise?view=powershell-6) - IDE utilizado
* [VirtualBox](https://www.virtualbox.org/) - Entorno de virtualización utilizado
* [Windows Server 2012 R2](https://www.microsoft.com/es-es/evalcenter/evaluate-windows-server-2012-r2) - Sistema operativo empleado para desplegar el directorio activo (AD)

## Autor

* **Carlos Garcia** - *Programación y documentación* - [c-garciao](https://gist.github.com/c-garciao)

## License

This project is licensed under the GNU License - see the [LICENSE.md](LICENSE.md) file for details

## Agradecimientos

* A Mario y Antonio, mis profesores de sistemas operativos
* Web documentación de [Microsoft](https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=win10-ps) 
