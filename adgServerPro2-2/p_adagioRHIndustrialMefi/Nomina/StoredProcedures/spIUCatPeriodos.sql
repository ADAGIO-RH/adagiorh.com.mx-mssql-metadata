USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [Nomina].[spIUCatPeriodos]  
(  
	@IDPeriodo int = 0  
	,@IDTipoNomina int  
	,@Ejercicio int  
	,@ClavePeriodo varchar(50)  
	,@Descripcion varchar(100)  
	,@FechaInicioPago date  
	,@FechaFinPago date  
	,@FechaInicioIncidencia date  
	,@FechaFinIncidencia date  
	,@Dias int  
	,@AnioInicio bit  
	,@AnioFin bit  
	,@MesInicio bit  
	,@MesFin bit  
	,@IDMes int  
	,@BimestreInicio bit  
	,@BimestreFin bit  
	,@General bit  
	,@Finiquito bit  
	,@Especial bit  
	,@Aguinaldo bit  
	,@PTU bit  
	,@DevolucionFondoAhorro bit  
	,@Presupuesto bit
	,@Cerrado bit 
	,@IDUsuario int 
)  
AS  
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUCatPeriodos]',
		@Tabla		varchar(max) = '[Nomina].[tblCatPeriodos]',
		@Accion		varchar(20)	= ''
  
	SET @ClavePeriodo = UPPER(@ClavePeriodo)  
	SET @Descripcion = UPPER(@Descripcion)  
  
	IF EXISTS(Select Top 1 1 from Nomina.tblCatPeriodos where ClavePeriodo = @ClavePeriodo and IDPeriodo <> isnull(@IDPeriodo,0))
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0406009'
		RETURN 0;
	END

	IF(@IDPeriodo = 0 or @IDPeriodo is null)  
	BEGIN  
		INSERT INTO Nomina.tblCatPeriodos(  
			IDTipoNomina  
			,Ejercicio  
			,ClavePeriodo  
			,Descripcion  
			,FechaInicioPago  
			,FechaFinPago  
			,FechaInicioIncidencia  
			,FechaFinIncidencia  
			,Dias  
			,AnioInicio  
			,AnioFin  
			,MesInicio  
			,MesFin  
			,IDMes  
			,BimestreInicio  
			,BimestreFin  
			,General  
			,Finiquito  
			,Especial
			,Aguinaldo
			,PTU
			,DevolucionFondoAhorro
			,Presupuesto
			,Cerrado  
		)  
		VALUES(  
			@IDTipoNomina  
			,@Ejercicio  
			,@ClavePeriodo  
			,@Descripcion  
			,@FechaInicioPago  
			,@FechaFinPago  
			,@FechaInicioIncidencia  
			,@FechaFinIncidencia  
			,case when @Dias = 0 or @dias is null then DATEDIFF(day,@FechaInicioPago,@FechaFinPago)+ 1  
				else @dias  
				end  
			,@AnioInicio  
			,@AnioFin  
			,@MesInicio  
			,@MesFin  
			,@IDMes  
			,@BimestreInicio  
			,@BimestreFin  
			,@General  
			,@Finiquito  
			,@Especial  
			,@Aguinaldo   
			,@PTU   
			,@DevolucionFondoAhorro 
			,@Presupuesto
			,@Cerrado    
		)  
  
		set @IDPeriodo = @@IDENTITY 
		
		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from Nomina.tblCatPeriodos  b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDPeriodo = @IDPeriodo
	END ELSE  
	BEGIN  
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from Nomina.tblCatPeriodos  b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDPeriodo = @IDPeriodo

		UPDATE Nomina.tblCatPeriodos  
			set IDTipoNomina	= @IDTipoNomina  
				,Ejercicio      = @Ejercicio  
				,ClavePeriodo	= @ClavePeriodo  
				,Descripcion	= @Descripcion  
				,FechaInicioPago	= @FechaInicioPago  
				,FechaFinPago		= @FechaFinPago  
				,FechaInicioIncidencia = @FechaInicioIncidencia  
				,FechaFinIncidencia    = @FechaFinIncidencia  
				,Dias       = case when @Dias = 0 or @dias is null then DATEDIFF(day,@FechaInicioPago,@FechaFinPago)+ 1  
						else @dias end  
				,AnioInicio	= @AnioInicio  
				,AnioFin	= @AnioFin  
				,MesInicio	= @MesInicio  
				,MesFin		= @MesFin  
				,IDMes		= @IDMes  
				,BimestreInicio	= @BimestreInicio  
				,BimestreFin	= @BimestreFin  
				,General		= @General  
				,Finiquito      = @Finiquito  
				,Especial		= @Especial  
				,Aguinaldo		=@Aguinaldo
				,PTU			= @PTU
				,DevolucionFondoAhorro = @DevolucionFondoAhorro
				,Presupuesto = @Presupuesto
				,Cerrado		= @Cerrado  
		WHERE IDPeriodo = @IDPeriodo   
		
		select @NewJSON = a.JSON
		from Nomina.tblCatPeriodos  b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDPeriodo = @IDPeriodo
	END  

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
  
	exec [Nomina].[spBuscarCatPeriodos] @IDPeriodo = @IDPeriodo, @Presupuesto = @Presupuesto, @IDUsuario = @IDUsuario 
  
 --SELECT p.IDPeriodo  
 --   , isnull(p.IDTipoNomina,0) as IDTipoNomina  
 --   ,tn.Descripcion as TipoNomina  
 --   , isnull(tn.IDPeriodicidadPago,0) as IDPeriodicidadPago  
 --   ,pp.Descripcion as PerioricidadPago  
 --   , ISNULL(tn.IDCliente,0) as IDCliente  
 --   , C.NombreComercial as Cliente  
 --   ,isnull(p.Ejercicio,0) as Ejercicio  
 --   ,p.ClavePeriodo  
 --   ,p.Descripcion  
 --   ,p.FechaInicioPago  
 --   ,p.FechaFinPago  
 --   ,p.FechaInicioIncidencia  
 --   ,p.FechaFinIncidencia  
 --   ,isnull(p.Dias,0) as Dias  
 --   ,isnull(p.AnioInicio,0) as AnioInicio  
 --   ,isnull(p.AnioFin,0) as AnioFin  
 --   ,isnull(p.MesInicio,0) as MesInicio  
 --   ,isnull(p.MesFin,0) as MesFin  
 --   ,p.IDMes  
 --   ,m.Descripcion Mes  
 --   ,isnull(p.BimestreInicio,0) as BimestreInicio  
 --   ,isnull(p.BimestreFin,0) as BimestreFin  
 --   ,isnull(p.General,0) as General  
 --   ,isnull(p.Finiquito,0) as Finiquito  
 --   ,isnull(p.Aguinaldo,0) as Aguinaldo  
 --   ,isnull(p.PTU,0) as PTU  
 --   ,isnull(p.Cerrado,0) as Cerrado  
  
 --FROM Nomina.tblCatPeriodos p  
 -- inner join Nomina.tblCatTipoNomina tn  
 --  on p.IDTipoNomina = tn.IDTipoNomina  
 -- inner join Sat.tblCatPeriodicidadesPago pp  
 --  on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago  
 -- inner join Nomina.tblCatMeses m  
 --  on p.IDMes = m.IDMes  
 -- inner join RH.tblCatClientes c  
 --  on tn.IDCliente = c.IDCliente  
 --where (p.IDPeriodo = @IDPeriodo)   
  
END
GO
