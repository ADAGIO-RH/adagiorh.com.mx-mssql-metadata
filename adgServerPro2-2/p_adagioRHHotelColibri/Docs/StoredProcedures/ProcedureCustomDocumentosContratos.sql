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


select @fechaContrato = FechaIni from rh.tblContratoEmpleado where IDContratoEmpleado = @IDContratoEmpleado

IF OBJECT_ID('TEMPDB..#tempCustomDatos') IS NOT NULL DROP TABLE #tempCustomDatos
IF OBJECT_ID('TEMPDB..#tempHistPuest') IS NOT NULL DROP TABLE #tempHistPuest
IF OBJECT_ID('TEMPDB..#tempHistSalario') IS NOT NULL DROP TABLE #tempHistSalario
IF OBJECT_ID('TEMPDB..#tempEmpleados') IS NOT NULL DROP TABLE #tempEmpleados
IF OBJECT_ID('TEMPDB..#tempDireccionRazonSocial') IS NOT NULL DROP TABLE #tempDireccionRazonSocial
IF OBJECT_ID('TEMPDB..#tempRazonSocialSiglas') IS NOT NULL DROP TABLE #tempRazonSocialSiglas

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')



Select   
 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,ROW_NUMBER() OVER(order by FechaIni desc) as RN
    into #tempHistPuest 
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

----
CREATE TABLE #tempCustomDatos(
		IDEmpleado int,
		Columna Varchar(255),
		Valor Varchar(255)
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

select * from  #tempCustomDatos
----


END
GO
