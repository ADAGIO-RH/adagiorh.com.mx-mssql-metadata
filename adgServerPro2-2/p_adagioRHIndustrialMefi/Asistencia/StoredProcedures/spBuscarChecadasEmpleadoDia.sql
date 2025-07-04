USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarChecadasEmpleadoDia](      
	@IDEmpleado int      
	,@Fecha date        
	,@IDUsuario int      
) as      
    declare 
		@IDIdioma varchar(max)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select     
		c.IDChecada,    
		c.Fecha,    
		isnull(c.FechaOrigen,'1900-01-01') as FechaOrigen,    
		isnull(l.IDLector,0) as IDLector,    
		ISNULL(l.Lector,'') as Lector,    
		c.IDEmpleado,    
		c.IDTipoChecada,    
		JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada ,    
		ISNULL(c.IDUsuario,0) as IDUsuario,    
		u.Cuenta as Cuenta,    
		isnull(c.Comentario,'') as Comentario,    
		ISNULL(c.IDZonaHoraria,0) as IDZonaHoraria,    
		z.Name as ZonaHoraria,    
		c.Automatica,    
		c.FechaReg    
	From Asistencia.tblChecadas c with (nolock)    
		left join Asistencia.tblLectores l (nolock) on l.IDLector = c.IDLector    
		left join Asistencia.tblCatTiposChecadas tc (nolock) on tc.IDTipoChecada = c.IDTipoChecada    
		left join Tzdb.Zones z (nolock) on c.IDZonaHoraria = z.Id    
		left join Seguridad.tblUsuarios u (nolock) on c.IDUsuario = u.IDUsuario    
	WHERE (cast(c.FechaOrigen as date) = @Fecha) and c.IDEmpleado = @IDEmpleado     
    order by c.Fecha
GO
