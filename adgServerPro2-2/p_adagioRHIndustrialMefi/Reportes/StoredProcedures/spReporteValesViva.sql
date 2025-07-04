USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteValesViva] --1,4,22,1
(
	@IDCliente int,
	@IDTipoNomina int,
	@IDPeriodo int,
	@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@FechaInicio Date
		,@FechaFin Date
		,@empleados [RH].[dtEmpleados]      
		,@IDConceptoVales int
		
		select top 1 @IDConceptoVales = IDConcepto from Nomina.tblCatConceptos where Codigo = '135' 

  


	Select @FechaInicio = p.FechaInicioPago
		  ,@FechaFin = p.FechaFinPago
	from Nomina.tblCatPeriodos p
	Where IDPeriodo = @IDPeriodo
	
  insert into @empleados     
  exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @FechaInicio, @Fechafin= @FechaFin , @IDUsuario = @IDUsuario                  
 
 -- select * from @empleados

	SELECT '5800' as Codigo,
		   e.ClaveEmpleado,
		   dp.ImporteTotal1 as MontoVales,
		   'DESPENSA CHIP' as Descripcion

	FROM Nomina.tblDetallePeriodo dp
		inner join @empleados e
			on e.IDEmpleado = dp.IDEmpleado
			and dp.IDConcepto = @IDConceptoVales 
			and dp.IDPeriodo = @IDPeriodo
		INNER JOIN RH.tblCatDatosExtra CDE
			on CDE.Nombre = 'TARJETA_VALES'
		left join RH.tblDatosExtraEmpleados DEE
			on DEE.IDEmpleado = e.IDEmpleado
			and DEE.IDDatoExtra = CDE.IDDatoExtra	
		where  isnull(dp.ImporteTotal1,0)> 0 
	ORDER BY E.ClaveEmpleado	
	
END
GO
