USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/****************************************************************************************************     
** Descripción  : Procedimiento para insertar/Actualizar el historial de metodos de pago de un Colaborador    
** Autor   : Jose Rafael Roman Gil    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 01/01/2018    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor    Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto   ¿Qué cambió?    
2018-05-07  JOSE RAFAEL ROMAN GIL Se Modifica para eliminar el banco y el concepto, ya que estos    
          estaran en la tabla de layout. Se agrega Usuario como Parametro    
2018-07-06  Jose Roman    Se agrega Procedure para proceso de Sincronizacion    
***************************************************************************************************/    
    
CREATE PROCEDURE [RH].[spUIPagoEmpleado](    
	@IDPagoEmpleado int = 0    
	,@IDEmpleado int    
	,@IDLayoutPago int    
	,@Cuenta Varchar(18)    
	,@Sucursal varchar(100)    
	,@Interbancaria Varchar(18)    
	,@Tarjeta Varchar(20)    
	,@IDBancario Varchar(15)    
	,@IDBanco int = 0    
	,@IDUsuario int    
)    
AS    
BEGIN    
Declare @msj nvarchar(max),
		@IDTipoLayout int,
		@IDConcepto int,
		@ImporteTotal int,
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@ValidaCLABEAltaEmpleados bit
	;

	Select @ValidaCLABEAltaEmpleados = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'ValidaCLABEAltaEmpleados'

	select 
		@Cuenta = REPLACE(@Cuenta,'_','')
		,@Interbancaria = REPLACE(@Interbancaria,' ','')
		,@Tarjeta = REPLACE(@Tarjeta,' ','')
    
    IF(ISNULL(@IDLayoutPago,0) = 0)    
    BEGIN    
		RETURN;    
    END   


   

	select top 1 
		@IDConcepto = lp.IDConcepto,
		@ImporteTotal = lp.ImporteTotal,
		@IDTipoLayout = tl.IDTipoLayout 
	from Nomina.tblLayoutPago lp with (nolock)
		inner join Nomina.tblCatTiposLayout tl with (nolock)
			on lp.IDTipoLayout = lp.IDTipoLayout
	where lp.IDLayoutPago = @IDLayoutPago
    
    IF(@IDPagoEmpleado = 0 or @IDPagoEmpleado is null)    
    BEGIN    
		if exists(select 1 
					from RH.tblPagoEmpleado with (nolock)    
					where IDEmpleado = @IDEmpleado and IDConcepto = @IDConcepto and ImporteTotal = @ImporteTotal and IDLayoutPago = @IDLayoutPago)    
		begin    
			set @msj= 'Ya existe un registro para pagar para este empleado de este tipo.(Layout,Concepto,Importe Total).';    
			raiserror(@msj,16,0);    
   
			return;    
		end;    

        
        
        IF EXISTS(Select top 1 1 from rh.tblPagoEmpleado where IDEmpleado = @IDEmpleado and IDConcepto = @IDConcepto)    
        BEGIN    
            SET @msj= 'Los Layouts de Pago utilizan el mismo concepto de pago y dará error al calcular la nomina.';    
            RAISERROR(@msj,16,0);    
            RETURN; 

        END   

		IF(@ValidaCLABEAltaEmpleados = 1 AND utilerias.CalcularUltimoDigitoCLABE(@Interbancaria) = 0)
		BEGIN
			SET @msj = 'El número de cuenta no es válido.';
			RAISERROR(@msj,16,0);
			RETURN;
		END
       
        	
    
		INSERT INTO RH.tblPagoEmpleado(IDEmpleado,IDLayoutPago,IDConcepto,ImporteTotal,Cuenta,Sucursal,Interbancaria,Tarjeta,IDBancario,IDBanco)    
		Values(@IDEmpleado    
			,case when @IDLayoutPago = 0 then null else @IDLayoutPago end  
			,@IDConcepto
			,@ImporteTotal  
			,@Cuenta,@Sucursal,@Interbancaria,@Tarjeta,@IDBancario    
			,case when @IDBanco = 0 then null else @IDBanco end ) 
		
		set @IDPagoEmpleado = @@IDENTITY

		select @NewJSON = a.JSON 
		from [RH].[tblPagoEmpleado] b with (nolock) 
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPagoEmpleado = @IDPagoEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPagoEmpleado]','[RH].[spUIPagoEmpleado]','INSERT',@NewJSON,''
    END    
    ELSE    
    BEGIN  
       
        --IF( (Select IDLayoutPago from rh.tblPagoEmpleado where IDPagoEmpleado = @IDPagoEmpleado) <> @IDLayoutPago AND @IDConcepto IN ( (Select IDConcepto from rh.tblPagoEmpleado where IDEmpleado = @IDEmpleado) )   )

		IF EXISTS(
			SELECT TOP 1 1
			FROM RH.tblPagoEmpleado PE
				INNER JOIN Nomina.tblLayoutPago LP
					on PE.IDLayoutPago = LP.IDLayoutPago
			WHERE PE.IDEmpleado = @IDEmpleado
			AND LP.IDConcepto = @IDConcepto
			AND PE.IDPagoEmpleado <> @IDPagoEmpleado
		)

        BEGIN    
            SET @msj= 'Los Layouts de Pago utilizan el mismo concepto de pago y dará error al calcular la nomina.';    
            RAISERROR(@msj,16,0);    
            RETURN; 
        END 

		IF(@ValidaCLABEAltaEmpleados = 1 AND utilerias.CalcularUltimoDigitoCLABE(@Interbancaria) = 0)
		BEGIN
			SET @msj = 'El número de cuenta no es válido.';
			RAISERROR(@msj,16,0);
			RETURN;
		END	
          
		select @OldJSON = a.JSON 
		from [RH].[tblPagoEmpleado] b with (nolock) 
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDPagoEmpleado = @IDPagoEmpleado

		UPDATE RH.tblPagoEmpleado    
		SET    
		   IDLayoutPago = case when @IDLayoutPago = 0 then null else @IDLayoutPago end 
		   ,IDConcepto = @IDConcepto
		   ,ImporteTotal = @ImporteTotal   
		   ,Cuenta = @Cuenta    
		   ,Sucursal = @Sucursal    
		   ,Interbancaria = @Interbancaria    
		   ,Tarjeta = @Tarjeta    
		   ,IDBancario = @IDBancario     
		   ,IDBanco = case when @IDBanco = 0 then null else @IDBanco end      
		WHERE IDEmpleado = @IDEmpleado    
		and IDPagoEmpleado = @IDPagoEmpleado    

		select @NewJSON = a.JSON 
		from [RH].[tblPagoEmpleado] b with (nolock) 
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPagoEmpleado = @IDPagoEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPagoEmpleado]','[RH].[spUIPagoEmpleado]','UPDATE',@NewJSON,@OldJSON
    END;    
    
	declare @tran int   
	set @tran = @@TRANCOUNT  
	if(@tran = 0)  
	BEGIN  
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado    
	END  
END
GO
