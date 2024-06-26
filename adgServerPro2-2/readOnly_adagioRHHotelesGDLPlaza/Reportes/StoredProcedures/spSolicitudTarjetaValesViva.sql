USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spSolicitudTarjetaValesViva] --1,4,22,1
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
		   e.Nombre,
		   e.SegundoNombre,
		   e.Paterno,
		   e.Materno,
		   e.RFC,
		   e.CURP,
		   e.IMSS,
		   'DESPENSA CHIP' as Descripcion,
		   1 as Numero

	FROM Nomina.tblDetallePeriodo dp
		inner join Nomina.tblCatConceptos c
			on c.IDConcepto = dp.IDConcepto
			and c.IDConcepto = @IDConceptoVales 
		inner join @empleados e
			on e.IDEmpleado = dp.IDEmpleado
		INNER JOIN RH.tblCatDatosExtra CDE
			on CDE.Nombre = 'TARJETA_VALES'
		left join RH.tblDatosExtraEmpleados DEE
			on DEE.IDEmpleado = e.IDEmpleado
			and DEE.IDDatoExtra = CDE.IDDatoExtra
	where
		DEE.IDDatoExtraEmpleado is null or isnull(DEE.Valor,'') = ''	
	ORDER BY E.ClaveEmpleado	
	
END
GO
