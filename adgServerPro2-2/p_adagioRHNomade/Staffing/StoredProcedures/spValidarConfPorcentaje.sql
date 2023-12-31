USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida configuracion de porcentajes masivo
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spValidarConfPorcentaje]
( 
	@dtConfPorcentajes [Staffing].[dtConfPorcentajes] READONLY
	, @IDUsuario INT 
)
AS
	BEGIN
		
		DECLARE @tempMessages AS TABLE( 
			ID INT,
			[Message] VARCHAR(500),
			Valid BIT
		)

		-- OBTENEMOS MSJ QUE PERTENECEN A LA DIRECCION ORGANIZACIONAL
		INSERT @tempMessages(ID, [Message], Valid)
        SELECT [IDMensajeTipo] ,
               [Mensaje]       ,
               [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionConfPorcentajeMap'
        ORDER BY [IDMensajeTipo];


		SELECT * 
		FROM @tempMessages

		SELECT * 
		FROM @dtConfPorcentajes

	END
GO
