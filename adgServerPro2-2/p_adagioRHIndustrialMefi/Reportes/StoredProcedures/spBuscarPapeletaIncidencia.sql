USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarPapeletaIncidencia]
(
	@IDIncidenciaEmpleado int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		IE.IDIncidencia
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,IE.Fecha
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,ISNULL(IE.Comentario,IE.ComentarioTextoPlano) AS Comentario
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,isnull((select top 1 em.NOMBRECOMPLETO from RH.tblJefesEmpleados JE inner join RH.tblEmpleadosMaster em on je.IDJefe = em.IDEmpleado where JE.IDEmpleado = M.IDEmpleado),'Jefe Supervisor') as Jefe
		, IE.IDIncidenciaEmpleado
	from Asistencia.tblIncidenciaEmpleado IE
		inner join Asistencia.tblCatIncidencias I on IE.IDIncidencia = I.IDIncidencia
		Inner join RH.tblEmpleadosMaster m on IE.IDEmpleado = m.IDEmpleado
		left join Asistencia.tblIncapacidadEmpleado IncaEmpleado on IncaEmpleado.IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado
	where IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleado
 	
END
GO
