#define SSCANF_NO_NICE_FEATURES
#include <a_samp>
#include <sscanf2>
#include <core>
#include <float>
#include <streamer>
#include <a_mysql>
#include <Pawn.CMD> // CMD es en mayusq (hay lo arregle)

// Coneccion con la db

#define IPDB 		"51.81.59.76"
#define USERDB 		"u3108285_T4Lb9MilLa"
#define PASSDB 		"QXt!@ZFYOUInM@YAybo1Bdia"
#define DATEBASE	"s3108285_qwq"


// dialog defines
// DIALOGS LOGIN
#define DIALOG_REGISTRO 0
#define DIALOG_GENERO 	1
#define DIALOG_EDAD 	2
#define DIALOG_INGRESO 	3
#define DIALOG_CORREO 	4
// DIALOG AYUDA
#define DIALOG_HELP     5
#define DIALOG_HELP2	6


//news

new MySQL:db;


//enums 
// aqui crearemos todos los datos que almacenaremos en la db
enum jInfo
{
Contra[128],
Correo[200],
Genero,
Edad,
Ropa,
Float:X,
Float:Y,
Float:Z,
Float:Vida,
Float:Chaleco,
Dinero
}

new Player[MAX_PLAYERS][jInfo];

main()
{
	print("\n----------------------------------");
	print("  Servidor iniciado\n");
	print("----------------------------------\n");
}

public OnPlayerConnect(playerid)
{
	new query[520], nombre[MAX_PLAYER_NAME];

	GetPlayerName(playerid, nombre, sizeof(nombre));
	mysql_format(db, query, sizeof(query), "SELECT * FROM `cuentas` WHERE `Nombre` ='%s'", nombre);
	mysql_pquery(db, query, "VerifyUser", "d", playerid);
	
	return 1;
}

public OnPlayerDisconnect(playerid){
	SaveData(playerid);
	return 1;
}
public OnPlayerSpawn(playerid)
{
    if (GetPVarInt(playerid, "PuedeIngresar") == 0)
    {
        // Congelar al jugador y evitar control
        TogglePlayerControllable(playerid, false);
        // También puedes moverlo a una posición segura o fuera del mapa
        SetPlayerPos(playerid, 0.0, 0.0, -100.0);
        return 0; // Evitar spawn normal
    }
    else
    {
        // Permitir control y spawn normal
        TogglePlayerControllable(playerid, true);
        return 1;
    }
}

public OnPlayerDeath(playerid, killerid, reason)
{
   	return 1;
}
// Vetifica si sigue el formato Nombre_Apellido
stock bool:ValidarNombreApellido(const nombre[])
{
    new len = strlen(nombre);
    new underscore_count = 0;
    for(new i = 0; i < len; i++)
    {
        if(nombre[i] == '_') underscore_count++;
    }
    if(underscore_count != 1) return false; // Debe tener solo un guion bajo
    
    // Que no empiece ni termine con '_'
    if(nombre[0] == '_' || nombre[len - 1] == '_') return false;
    
    return true;
}
// verificar si el correo es real
stock bool:VerifyCorreo(const correo[]){
	new len = strlen(correo);
    if (len < 10) return false; // 

    new final[11];
    strmid(final, correo, len - 10, len);//
    return strcmp(final, "@gmail.com", true) == 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	switch(dialogid)
	{
		case DIALOG_REGISTRO:{
			if(!response) return Kick(playerid);

			if(response){
				if(strlen(inputtext) < 3 ||strlen(inputtext) > 128){
					ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "Registro Invalido", "La clave debe tener mas de 3 digitos y menos de 100", "Registrar", "Cancelar");
					return 1;
				}
				new clave[128];
				ShowPlayerDialog(playerid, DIALOG_CORREO, DIALOG_STYLE_INPUT, "Registro -> Correo", "Ingrese un correo para ingresar.", "Registrar", "Cancelar");
				format(clave, sizeof(clave), "%s", inputtext);
				Player[playerid][Contra] = clave;
			}
		}

		case DIALOG_CORREO:{
			if(!response) return Kick(playerid);

			if(response){
				if(!VerifyCorreo(inputtext)){
					ShowPlayerDialog(playerid, DIALOG_CORREO, DIALOG_STYLE_INPUT, "Registro Invalido", "Porfavor ingrese un correo real (correo@gmail.com)", "Registrar", "Cancelar");
					return 1;
				}
				
				new correo[200];
				ShowPlayerDialog(playerid, DIALOG_GENERO, DIALOG_STYLE_MSGBOX, "Registro -> Genero", "Porfavor Selecione su genero", "Masculino", "Femenino");

				format(correo, sizeof(correo), "%s", inputtext);
				Player[playerid][Correo] = correo;
			}
		}

		case DIALOG_GENERO:{
			if(response){
				Player[playerid][Genero] = 0;
				Player[playerid][Ropa] = 299;
				ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Registro -> Edad", "Porfavor ingrese su edad Debe ser mayor a 16 y menor a 90", "Aceptar", "Cancelar");
			}
			else{
				Player[playerid][Genero] = 1;
				Player[playerid][Ropa] = 298;
				ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Registro -> Edad", "Porfavor ingrese su edad Debe ser mayor a 16 y menor a 90", "Aceptar", "Cancelar");
			}
		}
		
		case DIALOG_EDAD:{
			if(response){
				if(strval(inputtext) < 16|| strval(inputtext) > 90) return ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Registro Invalido", "Ingrese su edad\n\n Su edad no debe ser mayor a 90 y menor a 16", "Continuar", "Cancelar");
				Player[playerid][Edad] = strval(inputtext);
				SetSpawnInfo(playerid, 0, Player[playerid][Ropa], 1767.0145, -1896.5106, 13.5634, 0.0000, 0,0,0,0,0,0);
				SetPVarInt(playerid, "PuedeIngresar", 1);
				SpawnPlayer(playerid);
				CrearCuenta(playerid);
			}
			else{
				Kick(playerid);
			}
		}

		case DIALOG_INGRESO:{
			if(response){
				new query[520], nombre[MAX_PLAYER_NAME];
				GetPlayerName(playerid, nombre, sizeof(nombre));
				mysql_format(db, query, sizeof(query), "SELECT * FROM cuentas WHERE Nombre ='%s' AND clave='%s'", nombre, inputtext);
				mysql_pquery(db, query, "IngresoJugador", "d", playerid);
			}
			else{
				Kick(playerid);
			}
		}
			
		case DIALOG_HELP:
		{
			if(response){
				
				switch(listitem){
					case 0:{
						// Dialogo comandos
						ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "Comandos", "/test /csave", "Volver", "Cancelar");
					}
					case 1:{
                       ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "Vehiculos", "Aun no hay comandos espera la Actualizacion", "Volver", "Cancelar"); // despues de cada funcione pone ; si no nos dara error sis estaba resien arreglando lo otro
					}
					case 2:{
                       ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "Propiedade", "Aun no hay comandos espera la Actualizacion", "Volver", "Cancelar"); 
					}
					case 3:{
                       ShowPlayerDialog(playerid, DIALOG_HELP2, DIALOG_STYLE_MSGBOX, "Bandas", "Aun no hay comandos espera la Actualizacion", "Volver", "Cancelar"); 
					}
				}
				
			}
		}

		case DIALOG_HELP2:{
			if(!response) return 1;
			if(response){
				DialogHelp(playerid);
			}
		}
	}
	return 1;
}

forward SaveData(playerid);
public SaveData(playerid)
{
	new query[520],Float:jX,Float:jY,Float:jZ,Float:hp,Float:chale, nombre[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nombre, sizeof(nombre));
	GetPlayerPos(playerid, jX, jY, jZ);
	GetPlayerHealth(playerid, hp);
	GetPlayerArmour(playerid, chale);
	mysql_format(db, query, sizeof query, "UPDATE `cuentas` SET `Edad`='%i',`Ropa`='%i',`X`='%f',`Y`='%f',`Z`='%f',`Genero`='%i',`Vida`='%f',`Chaleco`='%f' WHERE `Nombre`='%s'", Player[playerid][Edad], Player[playerid][Ropa], jX, jY, jZ, Player[playerid][Genero], hp, chale, nombre);
	mysql_query(db, query);

	return 1;
}

forward IngresoJugador(playerid);
public IngresoJugador(playerid)
{
    new rows;
    cache_get_row_count(rows);

    if (rows == 0)
    {
        ShowPlayerDialog(playerid, DIALOG_INGRESO, DIALOG_STYLE_INPUT, "Ingreso", "¡Error!\n\nLa clave no es correcta.", "Continuar", "Cancelar");
    }
    else
    {
        cache_get_value_int(0, "Ropa", Player[playerid][Ropa]);
        cache_get_value_float(0, "X", Player[playerid][X]);
        cache_get_value_float(0, "Y", Player[playerid][Y]);
        cache_get_value_float(0, "Z", Player[playerid][Z]);
        cache_get_value_int(0, "Genero", Player[playerid][Genero]);
        cache_get_value_float(0, "Vida", Player[playerid][Vida]);
        cache_get_value_float(0, "Chaleco", Player[playerid][Chaleco]);
        cache_get_value_int(0, "Dinero", Player[playerid][Dinero]);
        cache_get_value_int(0, "Edad", Player[playerid][Edad]);

        SetPVarInt(playerid, "PuedeIngresar", 1);
        IngresarJugador(playerid);
    }
    return 1;
}

forward IngresarJugador(playerid);
public IngresarJugador(playerid)
{
	SetSpawnInfo(playerid, 0, Player[playerid][Ropa], Player[playerid][X], Player[playerid][Y],Player[playerid][Z], 0.0000, 0,0,0,0,0,0);
	SpawnPlayer(playerid);
	SetPlayerHealth(playerid,Player[playerid][Vida]);
	SetPlayerArmour(playerid,Player[playerid][Chaleco]);
	GivePlayerMoney(playerid,Player[playerid][Dinero]);
	SetPlayerSkin(playerid,Player[playerid][Ropa]);
	return 1;
}

forward CrearCuenta(playerid);
public CrearCuenta(playerid)
{	
	new nombre[MAX_PLAYER_NAME];
	new query[520];

	GetPlayerName(playerid, nombre, sizeof(nombre));

		
	if(!ValidarNombreApellido(nombre))
	{
		SendClientMessage(playerid, 0xFF0000AA, "Tu nombre debe tener formato Nombre_Apellido.");
		return Kick(playerid);
	}

	
	mysql_format(db, query, sizeof(query), 
		"INSERT INTO `cuentas` (`Nombre`, `Clave`, `Ropa`, `X`, `Y`, `Z`, `Genero`, `Vida`, `Dinero`) VALUES ('%s','%s',%i,1484.1082,-1668.4976,14.9159,%i,100,100000)", 
		nombre, Player[playerid][Contra], Player[playerid][Ropa], Player[playerid][Genero]);
		
	mysql_query(db, query);
		
	return 1;
}

forward DialogHelp(playerid);
public DialogHelp(playerid){
	// dialogo					0    	   1           2         3
	new str[500];
	format(str, sizeof(str), "Comandos\nVehiculos\nPropiedades\nBandas");
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Ayuda", str, "Aceptar", "Cancelar");
	return 1;
}
// verificamos si el usuario esta creado o no
forward VerifyUser(playerid);
public VerifyUser(playerid)
{
	new Rows;
	cache_get_row_count(Rows);
    if (!Rows)
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "Registro", "Bienvenido\n\nIngrese una clave para registrarse.", "Registrar", "Cancelar");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_INGRESO, DIALOG_STYLE_PASSWORD, "Ingreso", "Bienvenido\n\nIngrese su clave para ingresar.", "Continuar", "Cancelar");
    }
    return 1;
}


/////////////Reconocer Teclas

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	///Testeo N
	if ((newkeys & KEY_NO) && !(oldkeys & KEY_NO))
	{
	   //ejecutar la Accion de testeo de tecla N
	   SendClientMessage(playerid, 0xFE0303FF, "Has Testeado la tecla N teclas funcionando ");

	   /////////Despues De estos Abajo sera Para laas demas Funciones A testear Teclas //
	}
	return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	return 0;
}

public OnGameModeInit()
{
	SetGameModeText("Proyecto");
	ShowPlayerMarkers(1);
	ShowNameTags(1);


	CargarDB();

	return 1;
}

forward CargarDB();
public CargarDB(){
	db = mysql_connect(IPDB, USERDB, PASSDB, DATEBASE);

	if(db == MYSQL_INVALID_HANDLE){
		printf("Coneccion con la datebase fracasada");
		SendRconCommand("Exit");
	}
	else{
		printf("Coneccion con la datebase Exitosa");
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////comandos testear IC//

CMD:csave(playerid){
	SaveData(playerid);
	SendClientMessage(playerid, -1, "Datos Guardados");
	return 1;
}

CMD:test(playerid){
	SendClientMessage(playerid, -1, "comandos Funcionando");  //manda el mensaje de testeo
	return 1;
}

CMD:ayuda(playerid){
	DialogHelp(playerid);
	return 1;
}

CMD:testgithub(playerid){
	SendClientMessage(playerid, -1, "Test Github"); // vez?
	return 1;
}	