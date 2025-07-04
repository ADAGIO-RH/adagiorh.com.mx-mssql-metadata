USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetImportacion]          
(     
 @IDPeriodo int ,       
 @IDUsuario int,
 @DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacion] READONLY          
)          
AS          
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUICapturaDetallePeriodoSheetImportacion]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]',
		@Accion		varchar(20)		= 'IMPORTAR CAPTURAS',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @NewJSON = a.JSON
	from Nomina.tblCatPeriodos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDPeriodo,b.ClavePeriodo,b.Descripcion  For XML Raw)) ) a
	where IDPeriodo = @IDPeriodo

	declare  @msg varchar(max)
	--declare @DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacion]    

	if exists(select top 1 1 
			from @DetallePeriodoCapturaImportacion 
			where ClaveEmpleado is not null
			group by ClaveEmpleado,Codigo having count(*) > 1)
	begin
		set @Mensaje = 'Existen colaboradores con conceptos duplicados en el archivo.'

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

		raiserror(@Mensaje,16,1)
		return
	end;

	if exists(select top 1 1 
			from @DetallePeriodoCapturaImportacion dp
				join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
				join Nomina.tblCatTiposPrestamo ctp with (nolock) on ctp.IDConcepto = c.IDConcepto
			where dp.ClaveEmpleado is not null
			)
	begin
		
		select top 1 @msg='No pueda importar capturas a conceptos que están asociados a algún Tipo de Préstamo. ('+c.Codigo+' - '+c.Descripcion+')'
		from @DetallePeriodoCapturaImportacion dp
			join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
			join Nomina.tblCatTiposPrestamo ctp with (nolock) on ctp.IDConcepto = c.IDConcepto
		where dp.ClaveEmpleado is not null
		
		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

		raiserror(@msg,16,1)
		return
	end;

	EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

	select 1   
       
	MERGE Nomina.tblDetallePeriodo AS TARGET          
    USING @DetallePeriodoCapturaImportacion AS SOURCE          
		ON (TARGET.IDConcepto = SOURCE.IDConcepto           
			and TARGET.IDEmpleado = SOURCE.IDEmpleado          
			and TARGET.IDPeriodo = @IDPeriodo        
		)          
	WHEN MATCHED Then          
    update          
		Set               
		 TARGET.CantidadMonto	=  CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)<>0)THEN  isnull(SOURCE.CantidadMonto,0) ELSE 0 END          
		,TARGET.CantidadDias	=  CASE WHEN (ISNULL(SOURCE.CantidadDias,0)<>0) THEN  isnull(SOURCE.CantidadDias,0)  ELSE 0 END          
		,TARGET.CantidadVeces	=  CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)<>0)THEN  isnull(SOURCE.CantidadVeces,0) ELSE 0 END          
		,TARGET.CantidadOtro1	=  CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)<>0)THEN  isnull(SOURCE.CantidadOtro1,0) ELSE 0 END          
		,TARGET.CantidadOtro2	=  CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)<>0)THEN  isnull(SOURCE.CantidadOtro2,0) ELSE 0 END          
		,TARGET.ImporteGravado  =  CASE WHEN (ISNULL(SOURCE.ImporteGravado,0)<>0)THEN  isnull(SOURCE.ImporteGravado,0) ELSE 0 END          
		,TARGET.ImporteExcento  =  CASE WHEN (ISNULL(SOURCE.ImporteExcento,0)<>0)THEN	isnull(SOURCE.ImporteExcento,0) ELSE 0 END          
		,TARGET.ImporteOtro		=  CASE WHEN (ISNULL(SOURCE.ImporteOtro,0)<>0)	THEN  isnull(SOURCE.ImporteOtro,0) ELSE 0 END          
		,TARGET.ImporteTotal1	=  CASE WHEN (ISNULL(SOURCE.ImporteTotal1,0)<>0)THEN  isnull(SOURCE.ImporteTotal1,0) ELSE 0 END          
		,TARGET.ImporteTotal2	=  CASE WHEN (ISNULL(SOURCE.ImporteTotal2,0)<>0)THEN  isnull(SOURCE.ImporteTotal2,0) ELSE 0 END          
              
              
    WHEN NOT MATCHED BY TARGET THEN           
    INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2)          
    VALUES(SOURCE.IDEmpleado,@IDPeriodo,SOURCE.IDConcepto          
		,CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)<>0)THEN isnull(SOURCE.CantidadMonto,0) ELSE 0 END           
		,CASE WHEN (ISNULL(SOURCE.CantidadDias,0)<>0) THEN isnull(SOURCE.CantidadDias,0)  ELSE 0 END           
		,CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)<>0)THEN isnull(SOURCE.CantidadVeces,0) ELSE 0 END           
		,CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)<>0)THEN isnull(SOURCE.CantidadOtro1,0) ELSE 0 END           
		,CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)<>0)THEN isnull(SOURCE.CantidadOtro2,0) ELSE 0 END            
		,CASE WHEN (ISNULL(SOURCE.ImporteGravado,0)<>0)THEN isnull(SOURCE.ImporteGravado,0) ELSE 0 END            
		,CASE WHEN (ISNULL(SOURCE.ImporteExcento,0)<>0)THEN isnull(SOURCE.ImporteExcento,0) ELSE 0 END            
		,CASE WHEN (ISNULL(SOURCE.ImporteOtro,0)<>0)THEN isnull(SOURCE.ImporteOtro,0) ELSE 0 END            
		,CASE WHEN (ISNULL(SOURCE.ImporteTotal1,0)<>0)THEN isnull(SOURCE.ImporteTotal1,0) ELSE 0 END            
		,CASE WHEN (ISNULL(SOURCE.ImporteTotal2,0)<>0)THEN isnull(SOURCE.ImporteTotal2,0) ELSE 0 END            
    );        
        
          
          
END
GO
