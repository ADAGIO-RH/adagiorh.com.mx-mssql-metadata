USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear y modificar Familiares y Beneficiarios
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2018-07-09		Aneudy Abreu		    Se agregó el parámetro IDUsuario
***************************************************************************************************/
CREATE proc [RH].[spIUFamiliarBeneficiario](
	@IDFamiliarBenificiarioEmpleado int
    ,@IDEmpleado int 
    ,@IDParentesco int
    ,@NombreCompleto varchar(500)
    ,@FechaNacimiento date
    ,@Sexo char(1)
    ,@TelefonoMovil varchar(40)
    ,@TelefonoCelular varchar(40)
    ,@Emergencia bit 
    ,@Beneficiario bit 
    ,@Dependiente bit
	,@Porcentaje decimal(5,2) null  
    ,@IDUsuario int
) as 

set @NombreCompleto = UPPER(ISNULL(@NombreCompleto,''))

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
  

	IF(@Beneficiario = 1 and isnull(@Porcentaje,0) = 0)
	BEGIN
		RAISERROR('Un beneficiario necesita tener por lo menos un 1%%.',16,1);
		RETURN;
	END
	

    if (@IDFamiliarBenificiarioEmpleado  = 0 or @IDFamiliarBenificiarioEmpleado is null)
    begin
	   insert into [RH].[TblFamiliaresBenificiariosEmpleados](IDEmpleado, IDParentesco,NombreCompleto,FechaNacimiento,Sexo,TelefonoMovil
					   ,TelefonoCelular,Emergencia,Beneficiario,Dependiente,Porcentaje)
	   select @IDEmpleado,@IDParentesco,@NombreCompleto,@FechaNacimiento,@Sexo,@TelefonoMovil
					   ,@TelefonoCelular,@Emergencia,@Beneficiario,@Dependiente,@Porcentaje

	   select @IDFamiliarBenificiarioEmpleado = @@identity;

	   	select @NewJSON = a.JSON from [RH].[TblFamiliaresBenificiariosEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblFamiliaresBenificiariosEmpleados]','[RH].[spIUFamiliarBeneficiario]','INSERT',@NewJSON,''

    end else
    begin

		 select @OldJSON = a.JSON from [RH].[TblFamiliaresBenificiariosEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado

	   update [RH].[TblFamiliaresBenificiariosEmpleados]
		  set 		  
			  IDParentesco	    = @IDParentesco
			 ,NombreCompleto   = @NombreCompleto
			 ,FechaNacimiento  = @FechaNacimiento
			 ,Sexo		    = @Sexo
			 ,TelefonoMovil    = @TelefonoMovil
			 ,TelefonoCelular  = @TelefonoCelular
			 ,Emergencia	    = @Emergencia
			 ,Beneficiario	    = @Beneficiario
			 ,Dependiente	    = @Dependiente
			 ,Porcentaje		= @Porcentaje
	   where IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado

	    select @NewJSON = a.JSON from [RH].[TblFamiliaresBenificiariosEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblFamiliaresBenificiariosEmpleados]','[RH].[spIUFamiliarBeneficiario]','UPDATE',@NewJSON,@OldJSON

    end; 
    --	exec [Bk].[spIEmpleadoActualizado]
	   -- @IDEmpleado = @IDEmpleado
	   --,@Tabla = '[RH].[[TblFamiliaresBenificiariosEmpleados]]'
	   --,@IDUsuario = @IDUsuario
    exec [RH].[spBuscarFamiliarBeneficiario] @IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado
GO
