USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [Transporte].[spMapRutasPersonalExternos](
		@dtRutasPersonal  [Transporte].[dtRutasPersonal] readonly,
		@IDUsuario int
) as
     
	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)
    

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
        (2, 'La clave de la ruta 1 no existe.', 0),
        (3, 'El horario de la ruta de 1 no existe.', 0),        
        (4, 'La clave de la ruta 2 no existe.', 0),        
        (5, 'El horario de la ruta de 2 no existe.', 0),
		(6, 'La fecha inicial no puede ser mayor a la fecha final', 0),		
        (7, 'La ruta 1 se encuentra inactiva.', 0),
        (8, 'La ruta 2 se encuentra inactiva', 0),
        (9, 'Los nombres no pueden estar vacíos.', 0),
        (10, 'Los apellidos no pueden estar vacíos.', 0)

	select 
		info.*,
         (
			SELECT [Message] AS Message				
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDSMensaje, ',')
					)
			FOR JSON PATH
        ) AS Mensaje,        
		-- info.IDSMensaje as IDMensaje,        
		case when isnull(info.IDSMensaje,'')='' then cast(1 as bit) else cast(0 as bit) end as Valid
	from (
		select
            'EXTERNO' as ClaveEmpleado,
			0 as IDEmpleado,
            rp.Nombres,
            rp.Apellidos,
            rp.FechaInicio,
            rp.FechaFin,
            isnull(r1.IDRuta,0) AS [IDRuta1],
            rp.ClaveRuta1 as [ClaveRuta1],
            isnull(r1.Descripcion,0) AS [DescripcionRuta1],

            isnull(r2.IDRuta,0) AS [IDRuta2],
            rp.ClaveRuta2 as [ClaveRuta2],
            isnull(r2.Descripcion,0) AS [DescripcionRuta2],
            isnull(rh1.IDRutaHorario,0) [IDRutaHorario1],
            rp.HoraLlegada1,
            rp.HoraSalida1,
            isnull(rh2.IDRutaHorario,0) [IDRutaHorario2],
            rp.HoraLlegada2,
            rp.HoraSalida2,
			IDSMensaje = case 							
                            when isnull(rp.Nombres,'') ='' then '9,' else '' 
                        end + 
                        case
                            when isnull(rp.Apellidos,'') ='' then '10,' else '' 
                        end +
                        case
							when isnull(r1.IDRuta, 0) = 0 then '2,' else '' 
                        end +
                        case
                            when r1.[Status] = 0 then '7,' else '' 
                        end +
                        case
                            when isnull(rh1.IDRutaHorario,0)=0 then '3,'  else '' 
                        end +
                        case
                            when isnull(r2.IDRuta, 0) = 0 then '4,' else '' 
                        end +
                        case
                            when r2.[Status] = 0 then '8,' else '' 
                        end +
                        case
                            when isnull(rh2.IDRutaHorario,0)=0 then '5,' else '' 
                        end +
                        case
							when rp.FechaInicio > rp.FechaFin then '6,' else '' 						 
                        end 
		from @dtRutasPersonal rp
			left join Transporte.tblCatRutas r1 on r1.ClaveRuta=rp.ClaveRuta1
			left join Transporte.tblCatRutas r2 on r2.ClaveRuta=rp.ClaveRuta2
            left join Transporte.tblCatRutasHorarios rh1 on rh1.IDRuta=r1.IDRuta and rh1.HoraLlegada=rp.HoraLlegada1 AND rh1.HoraSalida=rp.HoraSalida1
            left join Transporte.tblCatRutasHorarios rh2 on rh2.IDRuta=r2.IDRuta and rh2.HoraLlegada=rp.HoraLlegada2 AND rh2.HoraSalida=rp.HoraSalida2

	 )  info
	order by FechaInicio
GO
