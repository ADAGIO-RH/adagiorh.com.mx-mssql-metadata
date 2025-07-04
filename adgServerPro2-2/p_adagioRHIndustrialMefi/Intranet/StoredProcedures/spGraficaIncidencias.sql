USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Intranet].[spGraficaIncidencias] --1,1279,2022
		@IDUsuario int,
		@IDEmpleado int,
		@Ejercicio int

	as Begin
	declare 
		 @IDIdioma Varchar(5)
		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
select (
select 
		
		JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as name	
		,count( I.IDIncidencia) as data
		,DATEPART  (month,IE.Fecha) as Mes
		,I.Color as Color
	from Asistencia.tblIncidenciaEmpleado IE with (nolock)	
		Left Join Asistencia.tblCatIncidencias I with (nolock) on IE.IDIncidencia = I.IDIncidencia
	WHERE IE.IDEmpleado=@IDEmpleado and IE.Autorizado= 1 and DATEPART (YEAR,IE.Fecha)=@Ejercicio
	group by  I.Traduccion
	,DATEPART (month,IE.Fecha)
	,I.Color 
	for json auto 
	)
	as JSonResult
	END
GO
