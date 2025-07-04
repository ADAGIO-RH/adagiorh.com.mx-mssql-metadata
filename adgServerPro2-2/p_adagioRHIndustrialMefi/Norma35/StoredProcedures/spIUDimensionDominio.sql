USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --Norma35.spIUDimensionDominio @IDEncuestaEmpleado=298, @IDDimensionDominio=0, @Dominio="Condiciones en el ambiente de trabajo",@IDDimension=1,@IDUsuario=1, @IDDominio=2
CREATE proc Norma35.spIUDimensionDominio(
    @IDEncuestaEmpleado int,
    @IDDimensionDominio int=0,
    @Dominio VARCHAR (250),
    @IDDimension int,
	@IDDominio int,
    @IDUsuario int

)
as BEGIN

   Declare @msj nvarchar(max) ;  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(isnull(@IDDimensionDominio,0) = 0)
	BEGIN
			if exists(select 1 from Norma35.TblDimensionesDeDominio 
						where IDEncuestaEmpleado=@IDEncuestaEmpleado 
						and  IDDominio = @IDDominio 
						and IDDimension=@IDDimension
						)  
		begin  
			set @msj= cast(@Dominio as varchar(50));  
			--raiserror(@msj,16,0);  
			exec [App].[spObtenerError]  
			 @IDUsuario  = 1,  
			 @CodigoError ='0302003',  
			 @CustomMessage = @msj  
			return;  
		end;  

		insert into Norma35.TblDimensionesDeDominio(
            IDEncuestaEmpleado,
            IDDimension,        
            Dominio,
			IDDominio)
		values
        (@IDEncuestaEmpleado,
        @IDDimension,
        @Dominio,
		@IDDominio
        )
		
        	set @IDDimensionDominio = @@IDENTITY

			select @NewJSON = a.JSON from [Norma35].[TblDimensionesDeDominio] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDDimensionDominio = @IDDimensionDominio

	    --EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[TblDimensionesDeDominio]','[Norma35].[spIUDimensionDominio]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Norma35].[TblDimensionesDeDominio] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDDominio = @IDDominio

		UPDATE [Norma35].[TblDimensionesDeDominio]
			set IDDimension = @IDDimension		
        	
		WHERE IDDimensionDominio = @IDDimensionDominio

		select @NewJSON = a.JSON from [Norma35].[TblDimensionesDeDominio] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDominio = @IDDominio

	     --EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[TblDimensionesDeDominio]','[Norma35].[spIUDimensionDominio]','INSERT',@NewJSON,@OldJSON
	END

END

--select * from App.tblCatErrores where Descripcion like '%Ya Existe%' 
GO
