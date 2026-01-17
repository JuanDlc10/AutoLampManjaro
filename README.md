# AutoLampManjaro 🚀

![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-00000F?logo=mysql&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-orange)

## Descripción

Script **Bash automatizado** diseñado específicamente para **Manjaro Linux**.  
Instala y configura de forma completa el stack **LAMP** (Apache, MariaDB, PHP) junto con **phpMyAdmin**, optimizando permisos y configuraciones del sistema automáticamente en **un solo paso**.

---

## Características principales

✔️ **Interfaz interactiva amigable**  
Solicita los datos necesarios durante la ejecución del script.

🔐 **Entrada segura de contraseña**  
Captura de credenciales para la base de datos de forma oculta.

⚡ **Auto-elevación de privilegios**  
El script detecta si no se ejecuta como root y solicita `sudo` automáticamente.

📂 **Gestión de permisos**  
Configuración automática de permisos recursivos `777` en `/srv/http/`.

🛠️ **Configuración de PHP**  
Activación de extensiones necesarias y manejo de errores.

🧹 **Auto-limpieza**  
Eliminación automática de la carpeta del repositorio tras finalizar la instalación.

✅ **Validación de entorno**  
Configurado para evitar errores de intérprete en sistemas **Arch / Manjaro**.

---

## Requisitos del sistema

- Bash (**v4.0+ recomendado**)
- Sistema operativo **Manjaro Linux** (o derivados de Arch)
- Conexión a internet activa
- Permisos de ejecución en el script
- Repositorios de **pacman** accesibles

---

## Instrucciones de uso básico

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/JuanDlc10/AutoLampManjaro
   ```

2. Entrar al directorio:
   ```bash
   cd AutoLampManjaro
   ```

3. Ejecutar el instalador:
   ```bash
   chmod +x instalar_lamp.sh
   ./instalar_lamp.sh
   ```

---

## Accesos una vez finalizado

- 🌐 **Servidor local:** http://localhost  
- 🗄️ **Gestor de base de datos:** http://localhost/phpmyadmin  
- 🧪 **Información PHP:** http://localhost/info.php  

---

## ⚠️ IMPORTANTE

Este script está diseñado para ser ejecutado **una sola vez** en **sistemas limpios**.  
Realiza modificaciones en archivos críticos de:

- `/etc/httpd/`
- `/etc/php/`

---

📜 Licencia MIT License - Ver archivo LICENSE para más detalles

👨💻 Autor Ezequiel Mendoza - @ezekingzote

👨💻 Automatización Juan Alberto De la cruz- @JuanDlc10
