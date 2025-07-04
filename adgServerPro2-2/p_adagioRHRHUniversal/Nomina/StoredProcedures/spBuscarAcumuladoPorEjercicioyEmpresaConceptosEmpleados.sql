USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca el acumulado por Fecha, Empresa, Conceptos y Colaboradores
** Autor			: Yessenia Leonel
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-04-16
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados] (
	@Ejercicio int,
	@CodigosConceptos varchar(max) = null,
	@dtEmpleados RH.dtEmpleados readonly,
	@IDUsuario int,
	@IDEmpresa int = null
) as

	declare
		@FechaInicial date = FORMATMESSAGE('%d-01-01', @Ejercicio),
		@FechaFin date = FORMATMESSAGE('%d-12-31', @Ejercicio)
		--,
		--@CodigosConceptos varchar(max) = '101',
		--@dtEmpleados RH.dtEmpleados --readonly
	;

		select 
			e.IDEmpleado,
			e.ClaveEmpleado, 
			e.NOMBRECOMPLETO as Colaborador, 
			c.Codigo as CodigoConcepto, 
			c.Descripcion as Concepto, 
			SUM(isnull(dp.ImporteTotal1,0)) as Total 
			--c.OrdenCalculo
		from RH.tblEmpleadosMaster e with (nolock) 
			join Nomina.tblDetallePeriodo dp with (nolock) on e.IDEmpleado = dp.IDEmpleado
			join Nomina.tblCatPeriodos P with (nolock) on dp.IDPeriodo = P.IDPeriodo and 
				isnull(p.Cerrado,0) = 1 and P.Ejercicio = @Ejercicio
			join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
			inner join (select ee.IDEmpleado, ee.FechaIni as EmpresaInicio, ee.FechaFin as EmpresaFin 
						from rh.tblEmpresaEmpleado ee with(nolock)
						where ee.IDEmpresa = @IDEmpresa --and ee.FechaIni <= @FechaFin and ee.FechaFin >= @FechaFin
						 ) Fempresa on Fempresa.IDEmpleado = e.IDEmpleado
		where (c.Codigo in (select item from App.Split(@CodigosConceptos, ',')) or @CodigosConceptos is null) and
				(e.IDEmpleado in (select IDEmpleado from @dtEmpleados) or (select COUNT(IDEmpleado) from @dtEmpleados) = 0) and 
				p.FechaFinPago between Fempresa.EmpresaInicio and Fempresa.EmpresaFin
		group by  e.IDEmpleado,e.ClaveEmpleado, e.NOMBRECOMPLETO, c.Codigo, c.Descripcion, c.OrdenCalculo
GO
