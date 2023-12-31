USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca trabajadores según la opción que recibe por parámetro.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-05
** Paremetros		:  
		@tipo    -1 : Todos los empleados
				  0  : Empleados Vigentes
				  1  : Empleados No Vigentes
				  2  : Cumpleaños hoy
				  3  : Cumpleaños en un fecha Específica   
				  4	 : Cumpleaños durante los proximos 5 dias
                  5  : Empleados Subordinados (Jefe-Empleado) -  INTRANET
                  6  : Empleados con Filtro Usuario (Empleados-Usuarios-Filtros) -  INTRANET
                 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2020-06-01			Jose Roman		Se agrega columna para la cantidad de solicitudes pendientes
									que tiene un colaborador en la intranet.
***************************************************************************************************/
CREATE proc [RH].[spBuscarEmpleadosTipo] --4,null,1
( 
		  @tipo int
		 ,@fecha date = null
		 ,@IDUsuario int
    )
as

	Declare @IDEmpleado int = 0

	select @IDEmpleado = IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario

    if (@tipo = -1)
    begin
		select em.*	,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	     
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		order by ClaveEmpleado asc
    end;
    if (@tipo = 0)
    begin
		select em.*	 ,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1
		order by em.ClaveEmpleado asc
    end;
    if (@tipo = 1)
    begin	   
		select em.*	 ,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 0
		order by em.ClaveEmpleado asc
    end;
    if (@tipo = 2)
    begin
	   print 'Cumpleaños hoy'
 
		select em.*	 ,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1 and
		  (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
		  and 
		  (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
		order by em.ClaveEmpleado asc
    end;
    if (@tipo = 3)
    begin
	   print 'Cumpleaños en un fecha Específica'

		select em.*	,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	     
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1 and
		  (datepart(month,em.FechaNacimiento) = datepart(month,@Fecha))
		  and 
		  (datepart(day,em.FechaNacimiento) = datepart(day,@Fecha))
		order by ClaveEmpleado asc
    end;

	if (@tipo = 4)
    begin
	   print 'Cumpleaños proximos 7 dias'

		select em.*	, 
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		WHERE  em.Vigente = 1 and
		((1 = (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()+5) / 365.25))
				  -
				  (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()) / 365.25))) OR
				  (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
				  and 
				  (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
				  )
		order by MONTH(em.FechaNacimiento) asc,DAY(em.FechaNacimiento) asc
    end;


	if (@tipo = 5)
    begin	   
		select em.*	,
		(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join RH.tblJefesEmpleados dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDJefe = @IDEmpleado
		where em.Vigente = 1
		and em.IDEmpleado <> @IDEmpleado
		order by  em.ClaveEmpleado asc
    end;
	if (@tipo = 6)
    begin
		select em.*, 
			(Select count(*) 
			from Intranet.tblSolicitudesEmpleado 
			where IDEmpleado = em.IDEmpleado 
				and IDEstatusSolicitud = 1 -- PENDIENTES
				 ) as SolicitudesPendientes	   
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario	
		where em.Vigente = 1
		and em.IDEmpleado <> @IDEmpleado
		order by em.ClaveEmpleado asc
    end;
GO
