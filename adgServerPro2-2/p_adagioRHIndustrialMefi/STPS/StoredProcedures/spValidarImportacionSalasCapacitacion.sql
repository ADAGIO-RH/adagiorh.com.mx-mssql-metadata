USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [STPS].[spValidarImportacionSalasCapacitacion](
	@dtSalasCapacitacion [STPS].[dtSalasCapacitacion] readonly
	,@IDUsuario int
)
as
begin
	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)

	insert @tempMessages(ID, [Message], Valid)
	values
		--(1, 'Datos Correctos', 1),
		(1, 'El nombre de la sala de capacitación es obligatorio', 0),
		-- (3, 'El nombre de la sala de capacitación no puede ser mayor a 50 caracteres', 0),
		-- (4, 'La ubicación de la sala de capacitación no puede ser mayor a 255 caracteres', 0),
        (2, 'El nombre de la sala de capacitación ya existe', 0),
        (3, 'El nombre de la sala de capacitación esta duplicado en esta misma importación', 0),
		(4, 'Para salas de capacitación sin capacidad especifica la capacidad por defecto es 0', 1),
		(5, 'Es recomendable especificar la ubicacion de la sala de capacitación', 1)
        

    IF OBJECT_ID('tempdb..#TempSalaCapacitacion') IS NOT NULL DROP TABLE #TempSalaCapacitacion; 

    SELECT 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RN,
    *
    INTO #TempSalaCapacitacion
    FROM @dtSalasCapacitacion;
    
    
	select
		info.*,
        (SELECT M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
	from (
		select 
			ISNULL(SC.Nombre, '') as Nombre,
			ISNULL(SC.Ubicacion, '') as Ubicacion,
			ISNULL(SC.Capacidad, 0) as Capacidad,
			IDMensaje = 
						 --case when len(ISNULL(SC.Nombre, '')) > 0 and len(ISNULL(SC.Ubicacion, '')) > 0 and ISNULL(TRY_CAST(SC.Capacidad AS INT), 0) > 0 then '1,' else '' end
                        -- case when ISNULL((select top 1 S.Nombre from #TempSalaCapacitacion S where S.Nombre = SC.Nombre), '') = '' then '2,' else '' end
                        +case when ISNULL(SC.Nombre, '') = '' then '1,' else '' end
                        + case when EXISTS(select top 1 1 from  [STPS].[tblSalasCapacitacion] S where S.Nombre = SC.Nombre )  then '2,' else '' end
                        + case when EXISTS(select top 1 1 from #TempSalaCapacitacion S where S.Nombre = SC.Nombre and s.RN <> SC.RN)  then '3,' else '' end
						+ case when ISNULL(SC.Capacidad, 0) = 0 then '4,' else '' end						
                        -- + case when ISNULL((select top 1 S.Ubicacion from #TempSalaCapacitacion S where S.Ubicacion = SC.Ubicacion), '') = '' then '6,' else '' end
                        + case when ISNULL(SC.Ubicacion, '') = '' then '5,' else '' end                        
						-- + case when ISNULL((select top 1 S.Nombre from #TempSalaCapacitacion S where S.Nombre = SC.Nombre and len(ISNULL(S.Nombre, '')) > 0 and len(ISNULL(S.Ubicacion, '')) > 0 and len(ISNULL(S.Capacidad, 0)) > 0), '') <> '' then '1' else '' end                                                
                        
                        
		from #TempSalaCapacitacion SC
	) info
	order by info.Nombre asc
end
GO
