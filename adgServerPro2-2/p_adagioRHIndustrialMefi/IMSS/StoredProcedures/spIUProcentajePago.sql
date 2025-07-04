USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spIUProcentajePago]      
(      
 @IDPorcentajesPago int = 0      
 ,@Fecha  date      
 ,@CuotaFija Decimal(18,10)      
 ,@ExcedentePatronal Decimal(18,10)      
 ,@ExcedenteObrera Decimal(18,10)      
 ,@PrestacionesDineroPatronal Decimal(18,10)      
 ,@PrestacionesDineroObrera Decimal(18,10)      
 ,@GMPensionadosPatronal    Decimal(18,10)      
 ,@GMPensionadosObrera    Decimal(18,10)      
 ,@RiesgosTrabajo     Decimal(18,10)      
 ,@InvalidezVidaPatronal    Decimal(18,10)      
 ,@InvalidezVidaObrera    Decimal(18,10)      
 ,@GuarderiasPrestacionesSociales  Decimal(18,10)      
 ,@CesantiaVejezPatron     Decimal(18,10)      
 ,@SeguroRetiro       Decimal(18,10)      
 ,@Infonavit        Decimal(18,10)      
 ,@CesantiaVejezObrera     Decimal(18,10)      
 ,@ReservaPensionado      Decimal(18,10)      
 ,@CuotaProporcionalObrera    Decimal(18,10)    
 ,@IDUsuario int  
)      
AS      
BEGIN      

		 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);


set @CuotaFija						= case when @CuotaFija <> 0 THEN @CuotaFija/100.00 else 0 END				 
set @ExcedentePatronal				= case when @ExcedentePatronal <> 0 THEN @ExcedentePatronal/100.00 else 0 END 
set @ExcedenteObrera				= case when @ExcedenteObrera <> 0 THEN @ExcedenteObrera/100.00 else 0 END     
set @PrestacionesDineroPatronal		= case when @PrestacionesDineroPatronal <> 0 THEN @PrestacionesDineroPatronal/100.00 else 0 END 
set @PrestacionesDineroObrera		= case when @PrestacionesDineroObrera <> 0 THEN @PrestacionesDineroObrera/100.00 else 0 END     
set @GMPensionadosPatronal			= case when @GMPensionadosPatronal <> 0 THEN @GMPensionadosPatronal/100.00 else 0 END 
set @GMPensionadosObrera			= case when @GMPensionadosObrera <> 0 THEN @GMPensionadosObrera/100.00 else 0 END     
set @RiesgosTrabajo					= case when @RiesgosTrabajo <> 0 THEN @RiesgosTrabajo/100.00 else 0 END 
set @InvalidezVidaPatronal			= case when @InvalidezVidaPatronal <> 0 THEN @InvalidezVidaPatronal/100.00 else 0 END 
set @InvalidezVidaObrera			= case when @InvalidezVidaObrera <> 0 THEN @InvalidezVidaObrera/100.00 else 0 END     
set @GuarderiasPrestacionesSociales = case when @GuarderiasPrestacionesSociales <> 0 THEN @GuarderiasPrestacionesSociales/100.00 else 0 END   
set @CesantiaVejezPatron			= case when @CesantiaVejezPatron <> 0 THEN @CesantiaVejezPatron/100.00 else 0 END     
set @SeguroRetiro					= case when @SeguroRetiro <> 0 THEN @SeguroRetiro/100.00 else 0 END     
set @Infonavit						= case when @Infonavit <> 0 THEN @Infonavit/100.00 else 0 END 
set @CesantiaVejezObrera			= case when @CesantiaVejezObrera <> 0 THEN @CesantiaVejezObrera/100.00 else 0 END     
set @ReservaPensionado				= case when @ReservaPensionado <> 0 THEN @ReservaPensionado/100.00 else 0 END 
set @CuotaProporcionalObrera		= case when @CuotaProporcionalObrera <> 0 THEN @CuotaProporcionalObrera/100.00 else 0 END   


       
 IF(@IDPorcentajesPago is null OR @IDPorcentajesPago = 0)      
 BEGIN      
  INSERT INTO IMSS.tblCatPorcentajesPago(Fecha      
   ,CuotaFija      
   ,ExcedentePatronal      
   ,ExcedenteObrera      
   ,PrestacionesDineroPatronal      
   ,PrestacionesDineroObrera      
   ,GMPensionadosPatronal      
   ,GMPensionadosObrera      
   ,RiesgosTrabajo      
   ,InvalidezVidaPatronal      
   ,InvalidezVidaObrera      
   ,GuarderiasPrestacionesSociales      
   ,CesantiaVejezPatron      
   ,SeguroRetiro      
   ,Infonavit      
   ,CesantiaVejezObrera      
   ,ReservaPensionado      
   ,CuotaProporcionalObrera      
  )      
  VALUES(      
   @Fecha      
  ,@CuotaFija      
  ,@ExcedentePatronal      
  ,@ExcedenteObrera      
  ,@PrestacionesDineroPatronal      
  ,@PrestacionesDineroObrera      
  ,@GMPensionadosPatronal      
  ,@GMPensionadosObrera      
  ,@RiesgosTrabajo      
  ,@InvalidezVidaPatronal      
  ,@InvalidezVidaObrera      
  ,@GuarderiasPrestacionesSociales      
  ,@CesantiaVejezPatron      
  ,@SeguroRetiro      
  ,@Infonavit      
  ,@CesantiaVejezObrera      
  ,@ReservaPensionado      
  ,@CuotaProporcionalObrera)      
      
		Set @IDPorcentajesPago = @@IDENTITY      
       select @NewJSON = a.JSON from [IMSS].[tblCatPorcentajesPago] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPorcentajesPago = @IDPorcentajesPago

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatPorcentajesPago]','[IMSS].[spIUCorreccionAccidente]','INSERT',@NewJSON,''
		
      
 END      
 ELSE      
 BEGIN  
 
   select @OldJSON = a.JSON from [IMSS].[tblCatPorcentajesPago] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPorcentajesPago = @IDPorcentajesPago
     
  UPDATE IMSS.tblCatPorcentajesPago      
  SET Fecha       = @Fecha             
   ,CuotaFija      = @CuotaFija            
   ,ExcedentePatronal    = @ExcedentePatronal          
   ,ExcedenteObrera    = @ExcedenteObrera           
   ,PrestacionesDineroPatronal  = @PrestacionesDineroPatronal        
   ,PrestacionesDineroObrera  = @PrestacionesDineroObrera        
   ,GMPensionadosPatronal   = @GMPensionadosPatronal         
   ,GMPensionadosObrera   = @GMPensionadosObrera          
   ,RiesgosTrabajo     = @RiesgosTrabajo           
   ,InvalidezVidaPatronal   = @InvalidezVidaPatronal         
   ,InvalidezVidaObrera   = @InvalidezVidaObrera          
   ,GuarderiasPrestacionesSociales = @GuarderiasPrestacionesSociales   
   ,ReservaPensionado = @ReservaPensionado      
  WHERE IDPorcentajesPago = @IDPorcentajesPago      
         
		 select @NewJSON = a.JSON from [IMSS].[tblCatPorcentajesPago] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPorcentajesPago = @IDPorcentajesPago

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatPorcentajesPago]','[IMSS].[spIUCorreccionAccidente]','UPDATE',@NewJSON,@OldJSON
		
      
      
 END      
      
  Select       
  IDPorcentajesPago      
  ,Fecha      
  ,CuotaFija							= case when CuotaFija <> 0 THEN CuotaFija * 100 else 0 END    
  ,ExcedentePatronal					= case when ExcedentePatronal <> 0 THEN ExcedentePatronal * 100 else 0 END 
  ,ExcedenteObrera      				= case when ExcedenteObrera <> 0 THEN ExcedenteObrera * 100 else 0 END 
  ,PrestacionesDineroPatronal      		= case when PrestacionesDineroPatronal <> 0 THEN PrestacionesDineroPatronal * 100 else 0 END 
  ,PrestacionesDineroObrera      		= case when PrestacionesDineroObrera <> 0 THEN PrestacionesDineroObrera * 100 else 0 END 
  ,GMPensionadosPatronal      			= case when GMPensionadosPatronal <> 0 THEN GMPensionadosPatronal * 100 else 0 END 
  ,GMPensionadosObrera      			= case when GMPensionadosObrera <> 0 THEN GMPensionadosObrera * 100 else 0 END 
  ,RiesgosTrabajo      					= case when RiesgosTrabajo <> 0 THEN RiesgosTrabajo * 100 else 0 END 
  ,InvalidezVidaPatronal      			= case when InvalidezVidaPatronal <> 0 THEN InvalidezVidaPatronal * 100 else 0 END 
  ,InvalidezVidaObrera      			= case when InvalidezVidaObrera <> 0 THEN InvalidezVidaObrera * 100 else 0 END 
  ,GuarderiasPrestacionesSociales      	= case when GuarderiasPrestacionesSociales <> 0 THEN GuarderiasPrestacionesSociales * 100 else 0 END 
  ,CesantiaVejezPatron      			= case when CesantiaVejezPatron <> 0 THEN CesantiaVejezPatron * 100 else 0 END 
  ,SeguroRetiro      					= case when SeguroRetiro <> 0 THEN SeguroRetiro * 100 else 0 END 
  ,Infonavit      						= case when Infonavit <> 0 THEN Infonavit * 100 else 0 END 
  ,CesantiaVejezObrera      			= case when CesantiaVejezObrera <> 0 THEN CesantiaVejezObrera * 100 else 0 END 
  ,ReservaPensionado      				= case when ReservaPensionado <> 0 THEN ReservaPensionado * 100 else 0 END 
  ,CuotaProporcionalObrera      		= case when CuotaProporcionalObrera <> 0 THEN CuotaProporcionalObrera * 100 else 0 END 
 From IMSS.tblCatPorcentajesPago      
 WHERE IDPorcentajesPago = @IDPorcentajesPago      
      
      
END
GO
