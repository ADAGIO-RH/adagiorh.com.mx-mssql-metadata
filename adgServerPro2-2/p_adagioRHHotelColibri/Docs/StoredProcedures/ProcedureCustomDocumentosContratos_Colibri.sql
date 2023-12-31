USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[Docs].[ProcedureCustomDocumentosContratos] @IDEmpleado = 197 , @FechaIni = '2020-02-05' , @Fechafin = '2020-02-05'   , @IDUsuario = 1   

*/

		 --substring(UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')+' '+COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')),1,49 ) AS NombreCompleto2      

Create PROCEDURE [Docs].[ProcedureCustomDocumentosContratos_Colibri] --@IDEmpleado = 299 , @FechaIni = '2022-10-02' , @Fechafin = '2022-10-02'   , @IDUsuario = 1  ,@IDIdioma = 'es-MX'
(
    @IDEmpleado int,        
    @FechaIni date = '1900-01-01',         
    @Fechafin date = '9999-12-31',
    @IDContratoEmpleado int = 0,
    @IDIdioma VARCHAR(5),    
    @empleados [RH].[dtEmpleados] READONLY,
    @IDUsuario int = 0           
)         
AS         
BEGIN
	
	IF OBJECT_ID('TEMPDB..#tempCustomDatos') IS NOT NULL DROP TABLE #tempCustomDatos
	IF OBJECT_ID('TEMPDB..#tempEmpleados') IS NOT NULL DROP TABLE #tempEmpleados

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	Select
	E.IDEmpleado
	,substring(UPPER(COALESCE(E.Nombre,'')+case when E.SegundoNombre<>'' then COALESCE(E.SegundoNombre,'') else '' end +' '+COALESCE(E.Paterno,'')+ case when E.Materno <> '' then +' '+COALESCE(E.Materno,'') else '' end),1,49 ) AS NombreCompleto2 
		into #tempEmpleados
	from @empleados E
	--from rh.tblempleadosMaster E
	where IDEmpleado = @IDEmpleado


	CREATE TABLE #tempCustomDatos(
			IDEmpleado int,
			Columna Varchar(255),
			Valor Varchar(255)
		)

	insert into #tempCustomDatos(IDEmpleado,Columna,Valor)
		Select idempleado,'NombreCompleto2', NombreCompleto2 as Valor
		from #tempEmpleados
		where idempleado = @IDEmpleado


	select * from  #tempCustomDatos
	----
END
GO
