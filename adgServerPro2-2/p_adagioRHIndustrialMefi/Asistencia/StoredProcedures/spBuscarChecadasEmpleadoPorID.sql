USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************   
** Descripción  : Buscar las Checadas por empleados por rangos de fecha  
** Autor   : Jose Roman
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-10-01  
** Paremetros  :     @IDEmpleado int  
     ,@FechaInicio date  
     ,@FechaFin date  
     ,@IDUsuario int        
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE proc [Asistencia].[spBuscarChecadasEmpleadoPorID]--28,20314,1
(  
     @IDChecada int  
	,@IDEmpleado int
    ,@IDUsuario int  
) as  

Declare 
@IDIdioma varchar(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	select 
		c.IDChecada,
		c.Fecha,
		isnull(c.FechaOrigen,'1900-01-01') as FechaOrigen,
		isnull(l.IDLector,0) as IDLector,
		ISNULL(l.Lector,'') as Lector,
		c.IDEmpleado,
		c.IDTipoChecada,
		JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada,
		ISNULL(c.IDUsuario,0) as IDUsuario,
		u.Cuenta as Cuenta,
		isnull(c.Comentario,'') as Comentario,
		ISNULL(c.IDZonaHoraria,0) as IDZonaHoraria,
		z.Name as ZonaHoraria,
		c.Automatica,
		c.FechaReg
	From Asistencia.tblChecadas c
		left join Asistencia.tblLectores l
			on l.IDLector = c.IDLector
		left join Asistencia.tblCatTiposChecadas tc
			on tc.IDTipoChecada = c.IDTipoChecada
		left join Tzdb.Zones z
			on c.IDZonaHoraria = z.Id
		left join Seguridad.tblUsuarios u 
			on c.IDUsuario = u.IDUsuario
	WHERE (c.IDChecada = @IDChecada) and c.IDEmpleado = @IDEmpleado
GO
