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
#define USERDB 		"u3123607_6XxOwXNJDd"
#define PASSDB 		"rNcb.EjTnzJkQ!ycY2c1Wm3="
#define DATEBASE	"s3123607_db1752377190569"


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

// DIALOG BAN
#define DIALOG_BAN 		7

////define colores
#define COLOR_RED 0xFF0000FF
#define COLOR_YELLOW 0xFFFF00FF

//news

new MySQL:db;

new const rankName[][] = {
	"Usuario",//0
	"Ayudante",//1
	"Moderador",//2
	"Moderador Global",//3
	"Encargado Staff",//4
	"CEO"//5
};

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
	Dinero,
	pAdmin,
	pBan
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
	// sistema de color blanco en el nombre
	new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    new newname[MAX_PLAYER_NAME + 3];
    format(newname, sizeof(newname), "~w~%s", name);
    SetPlayerName(playerid, newname);

   // sistema de login
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
// borra las _ de Nombre_Apellido 
stock ReplaceUnderscores(name[])
{
    for (new i = 0; name[i] != '\0'; i++)
    {
        if (name[i] == '_') name[i] = ' ';
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
    new name[MAX_PLAYER_NAME], msg[150];

    GetPlayerName(playerid, name, sizeof(name));
    ReplaceUnderscores(name);

    format(msg, sizeof(msg), "%s: %s", name, text);
    SendClientMessageToAll(-1, msg);
    return 0; 
}

public OnPlayerSpawn(playerid)
{
	if(Player[playerid][pBan] == 1){
			TogglePlayerControllable(playerid, false);
			SendClientMessage(playerid, -1, "Estas Baneado Contacta Crea ticket en discord");
			ShowPlayerDialog(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Baneado", "Te encuentras baneado Crea ticket en discord", "Aceptar", "Cerrar");
			return 1;
	}
    if (GetPVarInt(playerid, "PuedeIngresar") == 0)
    {
        // Congelar al jugador y evitar control
        TogglePlayerControllable(playerid, false);
        // Tambiùn puedes moverlo a una posiciùn segura o fuera del mapa
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
		case DIALOG_BAN:{
			if(response){
				Kick(playerid);
			}
			else {
				Kick(playerid);
			}
		}
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
	mysql_format(db, query, sizeof(query), "UPDATE `cuentas` SET `Edad`='%i',`Ropa`='%i',`X`='%f',`Y`='%f',`Z`='%f',`Genero`='%i',`Vida`='%f',`Chaleco`='%f', `Admin`='%i', `Ban`='%i' WHERE `Nombre`='%s'", Player[playerid][Edad], Player[playerid][Ropa], jX, jY, jZ, Player[playerid][Genero], hp, chale, Player[playerid][pAdmin], Player[playerid][pBan], nombre);
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
        ShowPlayerDialog(playerid, DIALOG_INGRESO, DIALOG_STYLE_INPUT, "Ingreso", "ùError!\n\nLa clave no es correcta.", "Continuar", "Cancelar");
    }
    else
    {
        new bool:isNull;

        cache_is_value_name_null(0, "Ropa", isNull);
        if (!isNull) cache_get_value_int(0, "Ropa", Player[playerid][Ropa]);

        cache_is_value_name_null(0, "X", isNull);
        if (!isNull) cache_get_value_float(0, "X", Player[playerid][X]);

        cache_is_value_name_null(0, "Y", isNull);
        if (!isNull) cache_get_value_float(0, "Y", Player[playerid][Y]);

        cache_is_value_name_null(0, "Z", isNull);
        if (!isNull) cache_get_value_float(0, "Z", Player[playerid][Z]);

        cache_is_value_name_null(0, "Genero", isNull);
        if (!isNull) cache_get_value_int(0, "Genero", Player[playerid][Genero]);

        cache_is_value_name_null(0, "Vida", isNull);
        if (!isNull) cache_get_value_float(0, "Vida", Player[playerid][Vida]);

        cache_is_value_name_null(0, "Chaleco", isNull);
        if (!isNull) cache_get_value_float(0, "Chaleco", Player[playerid][Chaleco]);

        cache_is_value_name_null(0, "Dinero", isNull);
        if (!isNull) cache_get_value_int(0, "Dinero", Player[playerid][Dinero]);

        cache_is_value_name_null(0, "Edad", isNull);
        if (!isNull) cache_get_value_int(0, "Edad", Player[playerid][Edad]);

        cache_is_value_name_null(0, "Admin", isNull);
        if (!isNull)
            cache_get_value_int(0, "Admin", Player[playerid][pAdmin]);
        else
            Player[playerid][pAdmin] = 0;

		cache_is_value_name_null(0, "Ban", isNull);
		if(!isNull)
			cache_get_value_int(0, "Ban", Player[playerid][pBan]);
		else{
			Player[playerid][pBan] = 0;
		}

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

	// Insertar todos los campos con valores por defecto si es necesario
	mysql_format(db, query, sizeof(query), 
	"INSERT INTO `cuentas` (`Nombre`, `Clave`, `Correo`, `Ropa`, `X`, `Y`, `Z`, `Genero`, `Vida`, `Dinero`, `Edad`, `Chaleco`, `Admin`, `Ban`) VALUES \
	('%s','%s','%s',%i,1767.0145,-1896.5106,13.5634,%i,100,0,0,0.0,0,0)",
	nombre, Player[playerid][Contra], Player[playerid][Correo], Player[playerid][Ropa], Player[playerid][Genero]);
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
		new banValue;
		cache_get_value_name_int(0, "Ban", banValue);
		Player[playerid][pBan] = banValue;
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


// admin system

CMD:daradmin(playerid, params[]){
	if(Player[playerid][pAdmin] < 4) return 0;
	new ID, ADMIN, str[200];
	if(sscanf(params, "dd", ID, ADMIN)) return SendClientMessage(playerid, -1, "Porfavor ocupa /daradmin [ID] [RANGO]");
	if(ID == playerid) return SendClientMessage(playerid, -1, "No puedes darte admin a ti mismo");
	if(!IsPlayerConnected(ID)) return 1;

	if(ADMIN == 0){
		Player[ID][pAdmin] = 0;
		SaveData(playerid);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Expulsaste del staff a %s", name);
		SendClientMessage(playerid, -1, str);
		SendClientMessage(ID, -1, str);
	}

	if(ADMIN == 1){
		Player[ID][pAdmin] = 1;
		SaveData(ID);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Le diste %s a %s",rankName[Player[ID][pAdmin]], name);
		SendClientMessage(playerid, -1, str);
		GetPlayerName(playerid, name, sizeof(name));
		format(str, sizeof(str), "%s Te ha dado %s", name, rankName[Player[ID][pAdmin]]);
		SendClientMessage(ID, -1, str);
	}
	if(ADMIN == 2){
		Player[ID][pAdmin] = 2;
		SaveData(ID);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Le diste %s a %s", rankName[Player[ID][pAdmin]], name);
		SendClientMessage(playerid, -1, str);
	}
	if(ADMIN == 3){
		Player[ID][pAdmin] = 3;
		SaveData(ID);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Le diste %s a %s",rankName[Player[ID][pAdmin]], name);
		SendClientMessage(playerid, -1, str);
		GetPlayerName(playerid, name, sizeof(name));
		format(str, sizeof(str), "%s Te ha dado %s", name, rankName[Player[ID][pAdmin]]);
		SendClientMessage(ID, -1, str);
	}
	if(ADMIN == 4){
		if(Player[playerid][pAdmin] == 4) return SendClientMessage(playerid, -1, "No puedes dar un rango mas alto que el tuyo");
		Player[ID][pAdmin] = 4;
		SaveData(ID);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Le diste %s a %s",rankName[Player[ID][pAdmin]], name);
		SendClientMessage(playerid, -1, str);
		GetPlayerName(playerid, name, sizeof(name));
		format(str, sizeof(str), "%s Te ha dado %s", name, rankName[Player[ID][pAdmin]]);
		SendClientMessage(ID, -1, str);
	}
	if(ADMIN == 5){
		if(Player[playerid][pAdmin] == 4) return SendClientMessage(playerid, -1, "No puedes dar un rango mas alto que el tuyo");
		Player[ID][pAdmin] = 5;
		SaveData(ID);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(ID, name, sizeof(name));
		format(str, sizeof(str), "Le diste %s a %s",rankName[Player[ID][pAdmin]], name);
		SendClientMessage(playerid, -1, str);
		GetPlayerName(playerid, name, sizeof(name));
		format(str, sizeof(str), "%s Te ha dado %s", name, rankName[Player[ID][pAdmin]]);
		SendClientMessage(ID, -1, str);
	}
	return 1;
}

// Comandos Admin

CMD:kick(playerid, params[]){
	new ID, name[MAX_PLAYER_NAME], str[100];
	if(Player[playerid][pAdmin] < 1) return 0;
	if(sscanf(params, "d", ID)) return SendClientMessage(playerid, -1, "Ocupa /kick [ID]");
	if(!IsPlayerConnected(ID) || ID == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "Id Invalido");
	if(ID == playerid) return SendClientMessage(playerid, -1, "No puedes kickearte a ti mismo");
	Kick(ID);
	GetPlayerName(ID, name, sizeof(name));
	format(str, sizeof(str), "Has kickeado al usuario %s", name);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:ban(playerid, params[]){
	new ID, name[MAX_PLAYER_NAME], str[100];
	if(Player[playerid][pAdmin] < 5) return 0;
	if(sscanf(params, "d", ID)) return SendClientMessage(playerid, -1, "Ocupa /ban [ID]");
	if(ID == playerid) return SendClientMessage(playerid, -1, "No puedes Banearte a ti mismo");
	if(!IsPlayerConnected(ID) || ID == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "Id Invalido");
	GetPlayerName(ID, name, sizeof(name));
	Player[ID][pBan] = 1;
	Kick(ID);
	format(str, sizeof(str), "Has Baneado al usuario %s", name);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:qban(playerid, params[]){
	if(Player[playerid][pAdmin] < 5) return 0;
	new name[24], query[520], str[100];
	if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, -1 ,"Ocupa /qban Nombre_Apellido");
	mysql_format(db, query, sizeof(query), "UPDATE cuentas SET Ban=0 WHERE Nombre='%e'", name);
	mysql_query(db, query);
	format(str, sizeof(str), "Le quitaste el baneo al usuario %s", name);
	SendClientMessage(playerid,COLOR_RED, str);
	return 1;
}


/////////////////////////////////////////////////////////////////////////////////////////////////
/////comandos testear IC//

CMD:csave(playerid){
	SaveData(playerid);
	SendClientMessage(playerid, -1, "Datos Guardados");
	return 1;
}

CMD:ayuda(playerid){
	DialogHelp(playerid);
	return 1;
}
	
///////////////////comandos basicos ///	
	