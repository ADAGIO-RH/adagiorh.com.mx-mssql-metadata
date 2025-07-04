USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [RH].[spMapDetalleCatTiposPrestaciones](
	  @detalleTiposPrestaciones [RH].[dtTiposPrestacionesDetalle] READONLY,
		@IDUsuario int
) as
	DECLARE @tempMessages AS TABLE( 
			ID INT
			, [Message] VARCHAR(500)
			, Valid BIT
		)
		
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionDetalleTipoPrestacionesMap'
        ORDER BY [IDMensajeTipo];
		
		select			
			Antiguedad,
			DiasVacaciones,
			DiasAguinaldo,
			PrimaVacacional,
            DiasExtra,
            PorcentajeExtra,
            CONVERT([decimal](19,5),(((365)+isnull([DiasAguinaldo],(0)))+isnull([DiasVacaciones],(0))*isnull([PrimaVacacional],(0)))/(365))+isnull([PorcentajeExtra],(0))	AS Factor
        
		into #dtDetalleTiposPrestaciones
        from @detalleTiposPrestaciones 

        SELECT INFO.*,
				-- SUB-CONSULTA QUE OBTIENE MENSAJE
				(SELECT '<b>*</b> ' + M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
		FROM (SELECT DTP.Antiguedad
					, DTP.DiasVacaciones
					, DTP.DiasAguinaldo
					, DTP.PrimaVacacional					
					, DTP.DiasExtra					
					, DTP.PorcentajeExtra					
					, DTP.Factor					
					, IDMensaje = IIF(ISNULL( DTP.Antiguedad, '') <> '', '', '1,') +
                     iif( (SELECT COUNT(*) 
                            FROM #dtDetalleTiposPrestaciones AS sub 
                            WHERE sub.Antiguedad = DTP.Antiguedad) > 1,'2','') 
			  FROM #dtDetalleTiposPrestaciones DTP) INFO
GO
