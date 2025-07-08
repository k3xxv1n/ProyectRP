#define SSCANF_NO_NICE_FEATURES
#include <a_samp>
#include <sscanf2>
#include <Pawn.CMD> // Incluir Pawn.CMD

#define COLOR_RED 0xFF0000FF
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_WHITE 0xFFFFFFFF

new PlayerFrozen[MAX_PLAYERS];

public OnFilterScriptInit()
{
    print("\n--------------------------------------");
    print(" Sistema Freezer cargado");
    print("--------------------------------------\n");
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerFrozen[playerid] = 0; // Resetear estado al conectar
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(PlayerFrozen[playerid])
    {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);

        if(ud != 0 || lr != 0)
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(playerid, x, y, z);
            SetPlayerPos(playerid, x, y, z);
        }
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(PlayerFrozen[playerid])
    {
        TogglePlayerControllable(playerid, 0);
    }
    return 1;
}

// Comando para congelar con Pawn.CMD
cmd:congelar(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) // Solo RCON admins
        return SendClientMessage(playerid, COLOR_RED, "Error: Necesitas ser admin RCON");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_YELLOW, "Uso: /congelar [ID de jugador]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "Error: Jugador no conectado");

    if(playerid == targetid)
        return SendClientMessage(playerid, COLOR_RED, "Error: No puedes congelarte a ti mismo");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);

    PlayerFrozen[targetid] = 1;
    TogglePlayerControllable(targetid, 0);

    // Guardar posición para evitar movimiento
    SetPVarFloat(targetid, "FreezeX", x);
    SetPVarFloat(targetid, "FreezeY", y);
    SetPVarFloat(targetid, "FreezeZ", z);

    new str[128], pName[24], tName[24];
    GetPlayerName(playerid, pName, sizeof(pName));
    GetPlayerName(targetid, tName, sizeof(tName));

    format(str, sizeof(str), "[ADMIN] %s ha congelado a %s", pName, tName);
    SendClientMessageToAll(COLOR_WHITE, str);

    return 1;
}

// Comando para descongelar con Pawn.CMD
cmd:descongelar(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) // Solo RCON admins
        return SendClientMessage(playerid, COLOR_RED, "Error: Necesitas ser admin RCON");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_YELLOW, "Uso: /descongelar [ID de jugador]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "Error: Jugador no conectado");

    PlayerFrozen[targetid] = 0;
    TogglePlayerControllable(targetid, 1);

    // Limpiar variables
    DeletePVar(targetid, "FreezeX");
    DeletePVar(targetid, "FreezeY");
    DeletePVar(targetid, "FreezeZ");

    new str[128], pName[24], tName[24];
    GetPlayerName(playerid, pName, sizeof(pName));
    GetPlayerName(targetid, tName, sizeof(tName));

    format(str, sizeof(str), "[ADMIN] %s ha descongelado a %s", pName, tName);
    SendClientMessageToAll(COLOR_WHITE, str);

    return 1;
}
