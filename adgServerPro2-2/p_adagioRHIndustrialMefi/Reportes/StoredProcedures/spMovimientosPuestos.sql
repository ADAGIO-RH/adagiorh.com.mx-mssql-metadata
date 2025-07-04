USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spMovimientosPuestos](  
 @FechaIni date  
 ,@FechaFin date  
 ,@IDCliente int  
 ,@IDUsuario int
) as  
SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  
  
declare   
  --@FechaIni date = getdate()  
  -- , @FechaFin date = getdate()  
  --,  
  @empleados [RH].[dtEmpleados],  
  @IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    
  insert @empleados  
  exec RH.spBuscarEmpleados @FechaIni = @FechaIni, @FechaFin = @FechaFin , @IDUsuario = @IDUsuario  
  
  
  delete from @empleados where IDCliente <> @IDCliente  
 -- if object_id('tempdb..#tempEmps') is not null drop table #tempEmps;  
  if object_id('tempdb..#tempPuestos') is not null drop table #tempPuestos;  
  if object_id('tempdb..#tempDepartamentos') is not null drop table #tempDepartamentos;  
  
  --select e.IDEmpleado,e.ClaveEmpleado,e.NOMBRECOMPLETO as NombreCompleto  
  --into #tempEmps  
  --from [RH].[tblEmpleadosMaster] e  
  
  select pe.*,
  JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto,
  ROW_NUMBER()OVER(partition by pe.IDEmpleado order by pe.FechaIni desc) as [Row]  
  INTO #tempPuestos  
  from [RH].[tblPuestoEmpleado] pe  
  join @empleados e on pe.IDEmpleado = e.IDEmpleado  
  join [RH].[tblCatPuestos] p on pe.IDPuesto = p.IDPuesto  
  
 delete from #tempPuestos where [Row] > 2  
  
 select de.*, JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Departamento,ROW_NUMBER()OVER(partition by de.IDEmpleado order by de.FechaIni desc) as [Row]  
 INTO #tempDepartamentos  
 from [RH].[tblDepartamentoEmpleado] de  
  join @empleados e on de.IDEmpleado = e.IDEmpleado  
  join [RH].[tblCatDepartamentos] d on de.IDDepartamento = d.IDDepartamento  
  
 delete from #tempPuestos where [Row] > 2  
 delete from #tempDepartamentos where [Row] > 2  
  
 select e.ClaveEmpleado  
  ,e.NOMBRECOMPLETO as NombreCompleto  
  ,deptoAnterior.Departamento as DepartamentoAnterior  
  ,deptoActual.Departamento as DepartamentoActual  
  ,deptoActual.FechaIni as FechaMovimientoDepartamentoActual  
  ,puestoAnterior.Puesto as PuestoAnterior  
  ,puestoActual.Puesto as PuestoActual  
  ,puestoActual.FechaIni as FechaMovimientoPuestoActual  
 from @empleados e  
  left join #tempDepartamentos deptoAnterior on e.IDEmpleado = deptoAnterior.IDEmpleado and deptoAnterior.[Row] = 2  
  left join #tempDepartamentos deptoActual on e.IDEmpleado = deptoActual.IDEmpleado and deptoActual.[Row] = 1  
  left join #tempPuestos puestoAnterior on e.IDEmpleado = puestoAnterior.IDEmpleado and puestoAnterior.[Row] = 2  
  left join #tempPuestos puestoActual on e.IDEmpleado = puestoActual.IDEmpleado and puestoActual.[Row] = 1  
  
 --select * from #tempPuestos  
 --select * from #tempDepartamentos
GO
