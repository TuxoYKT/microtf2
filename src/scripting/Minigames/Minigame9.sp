/**
 * MicroTF2 - Minigame 9
 * 
 * Simon Says!
 */

int Minigame9_Mode = -1;
bool Minigame9_CanCheckConditions = false;

public void Minigame9_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame9_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameFinishPre, INVALID_HANDLE, Minigame9_OnMinigameFinishPre);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame9_OnGameFrame);
}

public void Minigame9_OnMinigameSelectedPre()
{
	if (MinigameID == 9)
	{
		IsBlockingTaunts = false;
		Minigame9_Mode = GetRandomInt(1, 6);
		Minigame9_CanCheckConditions = false;

		CreateTimer(1.5, Timer_Minigame9_AllowConditions);
	}
}

public Action Timer_Minigame9_AllowConditions(Handle timer)
{
	Minigame9_CanCheckConditions = true;
}

public void Minigame9_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsInGame)
	{
		char text[64];

		switch (Minigame9_Mode)
		{
			case 1: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysTaunt", client);
			case 2: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysTaunt", client);
			case 3: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysJump", client);
			case 4: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysJump", client);
			case 5: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysCrouch", client);
			case 6: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysCrouch", client);
		}

		MinigameCaption[client] = text; 
	}
}

public void Minigame9_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 9)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && Minigame9_CanCheckConditions)
			{
				switch (Minigame9_Mode)
				{
					case 1:
					{
						if (TF2_IsPlayerInCondition(i, TFCond_Taunting) && PlayerStatus[i] != PlayerStatus_Winner) 
						{
							ClientWonMinigame(i);
						}
					}

					case 2: 
					{
						if (TF2_IsPlayerInCondition(i, TFCond_Taunting) && PlayerStatus[i] != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							MinigameCaption[i] = text;
							PlayerStatus[i] = PlayerStatus_Failed;
						}
					}

					case 3:
					{
						int button = GetClientButtons(i);

						if ((button & IN_JUMP) == IN_JUMP && PlayerStatus[i] != PlayerStatus_Winner) 
						{
							ClientWonMinigame(i);
						}
					}

					case 4:
					{
						int button = GetClientButtons(i);

						if ((button & IN_JUMP) == IN_JUMP && PlayerStatus[i] != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							MinigameCaption[i] = text;
							PlayerStatus[i] = PlayerStatus_Failed;
						}
					}

					case 5:
					{
						int button = GetClientButtons(i);

						if ((button & IN_DUCK) == IN_DUCK && PlayerStatus[i] != PlayerStatus_Winner)
						{
							ClientWonMinigame(i);
						}
					}

					case 6:
					{
						int button = GetClientButtons(i);

						if ((button & IN_DUCK) == IN_DUCK && PlayerStatus[i] != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							MinigameCaption[i] = text;
							PlayerStatus[i] = PlayerStatus_Failed;
						}
					}
				}
			}
		}
	}
}

public void Minigame9_OnMinigameFinishPre()
{
	if (IsMinigameActive && MinigameID == 9)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (Minigame9_Mode == 2)
				{
					if (!TF2_IsPlayerInCondition(i, TFCond_Taunting))
					{
						ClientWonMinigame(i);
					}
				}
				else if (Minigame9_Mode == 4) 
				{
					int button = GetClientButtons(i);

					if ((button & IN_JUMP) != IN_JUMP)
					{
						ClientWonMinigame(i);
					}
				}
				else if (Minigame9_Mode == 6)
				{
					int button = GetClientButtons(i);

					if ((button & IN_DUCK) != IN_DUCK)
					{
						ClientWonMinigame(i);
					}
				}
			}
		}
	}
}