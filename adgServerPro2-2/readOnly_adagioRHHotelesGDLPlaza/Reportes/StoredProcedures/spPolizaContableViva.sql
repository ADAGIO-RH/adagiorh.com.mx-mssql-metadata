USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spPolizaContableViva] --1,4,22,'POLIZA','2019-11-30','PD01',6,2,1
(
	@IDCliente int,
	@IDTipoNomina int,
	@IDPeriodo int,
	@Descripcion Varchar(max),
	@Fecha date,
	@Documento Varchar(Max) = 'PD01',
	@IDEmpresa int,
	@IDSucursal int,
	@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@FechaInicio Date
		,@FechaFin Date
		,@empleados [RH].[dtEmpleados]       

  



	Select @FechaInicio = p.FechaInicioPago
		  ,@FechaFin = p.FechaFinPago
	from Nomina.tblCatPeriodos p
	Where IDPeriodo = @IDPeriodo
	
  insert into @empleados     
  exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @FechaInicio, @Fechafin= @FechaFin , @IDUsuario = @IDUsuario                  
 
 -- select * from @empleados

	SELECT 
		FORMAT(@Fecha,'dd-MM-yyyy') as FECHA,
		@Documento as DOCUMENTO,
		0 as TIPOMOVIMIENTO,
		CASE WHEN c.IDTipoConcepto = 1 THEN c.CuentaCargo
			 ELSE c.CuentaAbono
			 END as NUMEROCUENTA,
		@Descripcion as DESCRIPCION,
		CASE WHEN c.IDTipoConcepto in (1,4,5) THEN SUM(dp.ImporteTotal1)
			 ELSE SUM(dp.ImporteTotal1) * -1
			 END IMPORTE,
		CASE WHEN e.Sucursal like '%AZTECA%' THEN 'AZTECA'
				ELSE 'MAYA'
				END as DEPARTAMENTO,
		cc.CuentaContable as PROGRAMA,
		c.OrdenCalculo
		--cc.Descripcion as CentroCosto,
		--c.IDTipoConcepto as TipoConcepto,
		--c.Codigo as CodigoConcepto,
		--c.Descripcion as Concepto
	FROM Nomina.tblDetallePeriodo dp
		inner join Nomina.tblCatConceptos c
			on c.IDConcepto = dp.IDConcepto
			and c.IDTipoConcepto in (select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion in ('PERCEPCION','DEDUCCION','OTROS TIPOS DE PAGOS','CONCEPTOS DE PAGO'))
		inner join @empleados e
			on e.IDEmpleado = dp.IDEmpleado
			and e.IDEmpresa = @IDEmpresa
			and e.IDSucursal = @IDSucursal
		inner join RH.tblCatCentroCosto cc
			on cc.IDCentroCosto = e.IDCentroCosto
	where 
		
		 ((ISNULL(C.CuentaAbono,'') <> '') OR (ISNULL(C.CuentaCargo,'') <> '')) 
		and dp.IDPeriodo = @IDPeriodo
		
	GROUP BY c.IDTipoConcepto,c.CuentaCargo,c.CuentaAbono, e.Sucursal, cc.CuentaContable, c.OrdenCalculo --,c.Descripcion, cc.Descripcion
END
GO
