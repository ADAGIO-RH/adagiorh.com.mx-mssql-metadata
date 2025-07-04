USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [Transporte].[spMapRutasPersonalEmpleados](
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
        (3, 'La clave de la ruta 2 no existe.', 0),        
        (4, 'La clave del empleado no existe.', 0),
        (5, 'La ruta 1 se encuentra inactiva.', 0),
        (6, 'La ruta 2 se encuentra inactiva', 0),        
        (7, 'El empleado ya tiene configurada una ruta para la fecha', 0),
        (8, 'El empleado no se encuentra vigente.', 0)
        
		

	select 
		info.*,
        case when m.ID =7 then 'El empleado ya tiene configurada una ruta para la fecha '+  FORMAT (info.FechaInicio, 'dd/MM/yyyy') 
            else  m.Message end as Mensaje,
		m.Valid
	from (
		select
            isnull(m.ClaveEmpleado,'') as ClaveEmpleado,
            isnull(m.IDEmpleado,0) as IDEmpleado,			
             case 														
                when isnull(m.ClaveEmpleado,'') ='' then '' 						
                else concat(m.Nombre,' ',m.SegundoNombre) end [Nombres],

             case 														
                    when isnull(m.ClaveEmpleado,'') ='' then '' 						
                    else concat(m.Paterno,' ',m.Materno) end [Apellidos],            
            rp.FechaInicio,
            rp.FechaFin,
            isnull(r1.IDRuta,0) AS [IDRuta1],
            rp.ClaveRuta1 as [ClaveRuta1],
            isnull(r1.Descripcion,0) AS [DescripcionRuta1],

            isnull(r2.IDRuta,0) AS [IDRuta2],
            rp.ClaveRuta2 as [ClaveRuta2],
            isnull(r2.Descripcion,0) AS [DescripcionRuta2],
            0 [IDRutaHorario1],
            rp.HoraLlegada1,
            rp.HoraSalida1,
            0 [IDRutaHorario2],
            rp.HoraLlegada2,
            rp.HoraSalida2,
			IDMensaje = case 							
							when isnull(r1.IDRuta, 0) = 0 then 2                            
                            when isnull(r2.IDRuta, 0) = 0 then 3                        
                            when r1.[Status] = 0 then 5                        
                            when r1.[Status] = 0 then 6                        
							when isnull(m.ClaveEmpleado,'') ='' then 4			
                            when m.Vigente=0  then 8			
                            when isnull(trp.IDRutaPersonal,0) <> 0 then 7 
						else 1 end
		from @dtRutasPersonal rp
			left join Transporte.tblCatRutas r1 on r1.ClaveRuta=rp.ClaveRuta1
			left join Transporte.tblCatRutas r2 on r2.ClaveRuta=rp.ClaveRuta2            
            left join RH.tblEmpleadosMaster m on m.ClaveEmpleado=rp.ClaveEmpleado                    
            left join Transporte.tblRutasPersonal trp on trp.IDEmpleado=m.IDEmpleado and (trp.FechaInicio =rp.FechaInicio or trp.FechaFin =rp.FechaInicio)

	) info join @tempMessages m on m.ID = info.IDMensaje
	order by FechaInicio
GO
