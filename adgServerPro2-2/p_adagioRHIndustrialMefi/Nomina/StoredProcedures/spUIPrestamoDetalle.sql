USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUIPrestamoDetalle] --0,2,100,'2017-12-28'  
(  
 @IDPrestamoDetalle int = 0,  
 @IDPrestamo int,  
 @MontoCuota decimal(18,4),  
 @FechaPago Date,
 @Receptor Varchar(255),
 @IDUsuario int  
)  
AS  
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIPrestamoDetalle]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamosDetalles]',
		@Accion		varchar(20)	= ''
	;

	declare 
		@MontoPrestamo decimal(18,4),  
		@EstatusPrestamo varchar(50),  
		@Saldo Decimal(18,4)  
	;

	if(ISNULL(@Receptor,'') = '')
	BEGIN
		set @Receptor = (Select top 1 UPPER(cuenta) from Seguridad.tblUsuarios where IDUsuario = @IDUsuario)
	END   
	ELSE
	BEGIN
		set @Receptor = UPPER(@Receptor)
	END
  
	SELECT @MontoPrestamo = (ISNULL(p.MontoPrestamo,0)+ISNULL(P.Intereses,0)),   
			@EstatusPrestamo = ep.Descripcion   
	FROM Nomina.tblPrestamos p  
		inner join Nomina.tblCatEstatusPrestamo ep  
			on p.IDEstatusPrestamo = ep.IDEstatusPrestamo  
	Where p.IDPrestamo = @IDPrestamo  
  
	select @Saldo = ISNULL(sum(MontoCuota),0) from Nomina.fnPagosPrestamo(@IDPrestamo)  


    -- SELECT @Saldo as Saldo, @MontoCuota as MontoCuota, @MontoPrestamo as MontoPrestamo
    -- RETURN
  
	IF((@Saldo + @MontoCuota)> @MontoPrestamo)  
	BEGIN  
		RAISERROR('Con la Cuota que desea aplicar Manualmente se supera el Monto Original del Prestamo.',16,1);  
		return;  
	END  
 
	IF(@EstatusPrestamo in( 'CANCELADO','SALDADO'))  
	BEGIN  
		RAISERROR('El préstamo esta en un estatus donde no se pueden agregar o modificar abonos.',16,1);  
		return;   
	END 

	IF(@IDPrestamoDetalle is null or @IDPrestamoDetalle = 0)  
	BEGIN  
		INSERT INTO Nomina.tblPrestamosDetalles(IDPrestamo,MontoCuota,FechaPago,Receptor,IDUsuario)  
		Values(@IDPrestamo,@MontoCuota,@FechaPago,@Receptor,@IDUsuario)  

		set @IDPrestamoDetalle = @@IDENTITY  

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblPrestamosDetalles b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoDetalle = @IDPrestamoDetalle

	END ELSE  
	BEGIN 
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblPrestamosDetalles b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoDetalle = @IDPrestamoDetalle

		UPDATE Nomina.tblPrestamosDetalles  
			set MontoCuota = @MontoCuota,  
				FechaPago = @FechaPago,
				Receptor = @Receptor,
				IDUsuario = @IDUsuario  
		where IDPrestamoDetalle = @IDPrestamoDetalle and IDPrestamo = @IDPrestamo  

		select @NewJSON = a.JSON
		from [Nomina].tblPrestamosDetalles b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoDetalle = @IDPrestamoDetalle
	END 
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
  
	IF(@EstatusPrestamo = 'NUEVO')  
	BEGIN  
		UPDATE Nomina.tblPrestamos  
		set IDEstatusPrestamo = (select TOP 1 IDEstatusPrestamo from Nomina.tblCatEstatusPrestamo where Descripcion = 'ACTIVO')  
		Where IDPrestamo = @IDPrestamo   
	END  
  
	select  p.IDPrestamo,    
		pd.IDPrestamoDetalle,    
		tp.IDConcepto,
        c.Codigo,    
		c.Descripcion as Concepto,    
		isnull(periodos.IDPeriodo,0) as IDPeriodo,    
		periodos.ClavePeriodo,    
		pd.MontoCuota,    
		pd.FechaPago,
		pd.Receptor,
		pd.IDUsuario,
		u.Cuenta as Usuario    
	from Nomina.tblCatTiposPrestamo tp    
		inner join Nomina.tblPrestamos p    
		on tp.IDTipoPrestamo = p.IDTipoPrestamo    
		inner join Nomina.tblCatEstatusPrestamo ep    
		on ep.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join Nomina.tblPrestamosDetalles pd    
		on p.IDPrestamo = pd.IDPrestamo    
		left join Nomina.tblCatConceptos c    
		on tp.IDConcepto = c.IDConcepto    
		left join Nomina.tblCatPeriodos periodos    
		on periodos.IDPeriodo = pd.IDPeriodo 
		left join Seguridad.tblUsuarios u 
		on u.IDUsuario = pd.IDUsuario
	Where p.IDPrestamo = @IDPrestamo and pd.IDPrestamoDetalle = @IDPrestamoDetalle  
  
END
GO
