USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[ProcedureCustomDocumentosContratos] --@IDEmpleado = 299 , @FechaIni = '2022-10-02' , @Fechafin = '2022-10-02'   , @IDUsuario = 1  ,@IDIdioma = 'es-MX'
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
DECLARE
@fechaContrato date
,@FechaIniContrato DATE
,@Duracion INT;


select @fechaContrato = FechaIni from rh.tblContratoEmpleado where IDContratoEmpleado = @IDContratoEmpleado
select @FechaIniContrato = FechaFin from rh.tblcontratoempleado where idcontratoempleado = @IDContratoEmpleado
select @Duracion = Duracion from rh.tblcontratoempleado where idcontratoempleado = @IDContratoEmpleado

IF OBJECT_ID('TEMPDB..#tempCustomDatos') IS NOT NULL DROP TABLE #tempCustomDatos
IF OBJECT_ID('TEMPDB..#tempHistPuest') IS NOT NULL DROP TABLE #tempHistPuest
IF OBJECT_ID('TEMPDB..#tempHistPuestoActual') IS NOT NULL DROP TABLE #tempHistPuestoActual
IF OBJECT_ID('TEMPDB..#tempHistPuestoActualDescripcion') IS NOT NULL DROP TABLE #tempHistPuestoActualDescripcion
IF OBJECT_ID('TEMPDB..#tempHistSalario') IS NOT NULL DROP TABLE #tempHistSalario
IF OBJECT_ID('TEMPDB..#tempEmpleados') IS NOT NULL DROP TABLE #tempEmpleados
IF OBJECT_ID('TEMPDB..#tempDireccionRazonSocial') IS NOT NULL DROP TABLE #tempDireccionRazonSocial
IF OBJECT_ID('TEMPDB..#tempRazonSocialSiglas') IS NOT NULL DROP TABLE #tempRazonSocialSiglas
IF OBJECT_ID('TEMPDB..#tempJefes') IS NOT NULL DROP TABLE #tempJefes
IF OBJECT_ID('TEMPDB..#tempFechaFin') IS NOT NULL DROP TABLE #tempFechaFin

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

Select   
 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,ROW_NUMBER() OVER(order by FechaIni desc) as RN
    into #tempHistPuest 
from rh.tblPuestoEmpleado e inner join rh.tblCatPuestos cp on cp.IDPuesto = e.IDPuesto
where IDEmpleado = @IDEmpleado 

Select   
 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,ROW_NUMBER() OVER(order by FechaIni desc) as RN
    into #tempHistPuestoActual 
from rh.tblPuestoEmpleado e inner join rh.tblCatPuestos cp on cp.IDPuesto = e.IDPuesto
where IDEmpleado = @IDEmpleado 

Select   
 ISNULL(DescripcionPuesto,'') AS DescripcionPuestoActual,ROW_NUMBER() OVER(order by FechaIni desc) as RN
    into #tempHistPuestoActualDescripcion 
from rh.tblPuestoEmpleado e inner join rh.tblCatPuestos cp on cp.IDPuesto = e.IDPuesto
where IDEmpleado = @IDEmpleado 

select * , ROW_NUMBER()OVER(order by Fecha desc) as RN 
into #tempHistSalario
from IMSS.tblMovAfiliatorios
where IDEmpleado = @IDEmpleado and IDTipoMovimiento <> 2

Select
	E.IDEmpleado
	,substring(UPPER(COALESCE(E.Nombre,'')+' '+case when E.SegundoNombre<>'' then COALESCE(E.SegundoNombre,'') else '' end +' '+COALESCE(E.Paterno,'')+ case when E.Materno <> '' then +' '+COALESCE(E.Materno,'') else '' end),1,49 ) AS NombreCompleto2 
		into #tempEmpleados
	from @empleados E
	--from rh.tblempleadosMaster E
	where IDEmpleado = @IDEmpleado

Select
	   M.IDEmpleado
	  ,VDE.Valor
	   into #tempDireccionRazonSocial
	from RH.tblEmpleadosMaster M
		 LEFT JOIN RH.tblEmpresa E ON E.IDempresa = M.IDEmpresa
		 LEFT JOIN App.tblValoresDatosExtras VDE ON VDE.IDReferencia = E.IDEmpresa
		 LEFT JOIN App.tblCatDatosExtras CDE ON CDE.IDDatoExtra = VDE.IDDatoExtra
	where 
		  M.IDEmpleado = @IDEmpleado
		  AND VDE.IDDatoExtra = 1
		  AND VDE.IDReferencia = (SELECT IDEmpresa AS IDReferencia FROM RH.tblEmpleadosMaster WHERE IDEmpleado = @IDEmpleado)

Select
	   M.IDEmpleado
	  ,VDE.Valor
	   into #tempRazonSocialSiglas
	from RH.tblEmpleadosMaster M
		 LEFT JOIN RH.tblEmpresa E ON E.IDempresa = M.IDEmpresa
		 LEFT JOIN App.tblValoresDatosExtras VDE ON VDE.IDReferencia = E.IDEmpresa
		 LEFT JOIN App.tblCatDatosExtras CDE ON CDE.IDDatoExtra = VDE.IDDatoExtra
	where 
		  M.IDEmpleado = @IDEmpleado
		  AND VDE.IDDatoExtra = 2
		  AND VDE.IDReferencia = (SELECT IDEmpresa AS IDReferencia FROM RH.tblEmpleadosMaster WHERE IDEmpleado = @IDEmpleado) 


SELECT
	 E.IDEmpleado
	,Jefes.NombreJefe AS Jefe
INTO #tempJefes
FROM @empleados E
INNER JOIN (SELECT 
				 E.IDEmpleado
				,E.ClaveEmpleado
				,E.NOMBRECOMPLETO
				,J.IDEmpleado AS IDJefe
				,J.ClaveEmpleado AS ClaveJefe
				,J.NOMBRECOMPLETO AS NombreJefe
			FROM RH.tblJefesEmpleados JE
			INNER JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado = JE.IDEmpleado
			INNER JOIN RH.tblEmpleadosMaster J ON J.IDEmpleado = JE.IDJefe) Jefes ON Jefes.IDEmpleado = E.IDempleado
WHERE Jefes.IDEmpleado = @IDEmpleado


Select 
	 E.idempleado
	--,CAST(FORMAT(DATEADD(DAY,-1,DATEADD(DAY,@Duracion,@FechaIniContrato)),'dd/MM/yyyy') as varchar(10)) AS FechaEvaluacion
	,cast(format(@FechaIniContrato,'dd/MM/yyyy') as varchar(10)) AS FechaEvaluacion
into #tempFechaFin
from @empleados e
where IDEmpleado = @IDEmpleado
----
CREATE TABLE #tempCustomDatos(
		IDEmpleado int,
		Columna Varchar(255),
		Valor Varchar(MAX)
	)

insert into #tempCustomDatos(IDEmpleado,Columna,Valor)

Select idempleado,'NumContrato', isnull(cast (Count(*) as varchar),0) as Valor 
    from rh.tblContratoEmpleado 
        where 
             idempleado = @IDEmpleado 
            and FechaIni <= @fechaContrato
group by IDEmpleado
UNION
Select top 1 @IDEmpleado,'CEO',isnull(NOMBRECOMPLETO,'') as Valor 
    from rh.tblEmpleadosMaster
        where Puesto = 'CEO'
UNION
Select @IDEmpleado,'PuestoAnterior',Descripcion as  Valor from #tempHistPuest
where RN = 2
UNION
Select @IDEmpleado,'PuestoActual',Descripcion as  Valor from #tempHistPuestoActual
where RN = 1
UNION
Select @IDEmpleado,'SalarioAnterior', cast (SalarioDiario as varchar) as Valor from #tempHistSalario
where RN = 2 
UNION 
Select idempleado,'NombreCompleto2', NombreCompleto2 as Valor
from #tempEmpleados
where idempleado = @IDEmpleado
UNION
Select idempleado,'DireccionRazonSocial', Valor as Valor
from #tempDireccionRazonSocial
where idempleado = @IDEmpleado
UNION
Select idempleado,'RazonSocialSiglas', Valor as Valor
from #tempRazonSocialSiglas
where idempleado = @IDEmpleado
UNION ALL
Select idempleado,'Jefe',Jefe as Valor
from #tempJefes
where IDEmpleado = @IDEmpleado
UNION ALL
Select idempleado,'FechaEvaluacion',FechaEvaluacion as Valor
from #tempFechaFin
where IDEmpleado = @IDEmpleado
UNION
Select @IDEmpleado,'DescripcionPuestoActual',DescripcionPuestoActual as Valor from #tempHistPuestoActualDescripcion
where RN = 1

select * from  #tempCustomDatos
----


END
GO
