USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Insertar/Actualizar la sección de Salud del colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-06-11  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-06-19  Aneudy Abreu  Se agregarón los campos: Alergias y Brigadas  
2018-06-20  Jose Roman          Se agrega Categoria de IMC y Tratamiento de Alergias   
2018-07-06  Jose Roman  Se agrega Procedure para proceso de Sincronizacion  
2018-07-09  Aneudy Abreu  Corregí un problema para evitar que se dupliquen registros por empleados  
        Se agregó el parámetro IDUsuario  
***************************************************************************************************/  
CREATE proc [RH].[spIUSaludEmpleado](  
     @IDSaludEmpleado int  
    ,@IDEmpleado int  
    ,@TipoSangre varchar(10)  
    ,@Estatura decimal(10,2)  
    ,@Peso decimal(10,2)  
    ,@IMC decimal(10,2)  
    ,@IMCC Varchar(255)  
    ,@Alergias nvarchar(max)  
	,@TratamientoAlergias nvarchar(max)  
    ,@Brigadas nvarchar(max)  
    ,@UMF varchar(10) 
	,@RequiereTarjetaSalud bit = 0
	,@VencimientoTarjeta date
    ,@IDUsuario int  
) as   
    select @IDSaludEmpleado=isnull(IDSaludEmpleado,0)  
    from [RH].[TblSaludEmpleado] with (NOLOCK)  
    where IDEmpleado = @IDEmpleado  

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

  
    if (@IDSaludEmpleado = 0 or @IDSaludEmpleado is null)  
    begin  
		insert into [RH].[TblSaludEmpleado](IDEmpleado,TipoSangre,Estatura,Peso,IMC,IMCC,Alergias,TratamientoAlergias,RequiereTarjetaSalud,VencimientoTarjeta)  
		select @IDEmpleado,@TipoSangre,@Estatura,@Peso,@IMC,@IMCC,@Alergias,@TratamientoAlergias, @RequiereTarjetaSalud,@VencimientoTarjeta
  
		select @IDSaludEmpleado = @@identity;  

		select @NewJSON = a.JSON from [RH].[TblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSaludEmpleado = @IDSaludEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblSaludEmpleado]','[RH].[spIUSaludEmpleado]','INSERT',@NewJSON,''

    end else  
    begin  

		select @OldJSON = a.JSON from [RH].[TblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSaludEmpleado = @IDSaludEmpleado

		update [RH].[TblSaludEmpleado]  
		set TipoSangre = @TipoSangre  
		,Estatura = @Estatura  
		,Peso = @Peso  
		,IMC = @IMC  
		,IMCC = @IMCC  
		,Alergias = @Alergias  
		,TratamientoAlergias = @TratamientoAlergias
		,RequiereTarjetaSalud = @RequiereTarjetaSalud
		,VencimientoTarjeta = @VencimientoTarjeta  
		where IDSaludEmpleado = @IDSaludEmpleado  

		select @NewJSON = a.JSON from [RH].[TblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSaludEmpleado = @IDSaludEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblSaludEmpleado]','[RH].[spIUSaludEmpleado]','UPDATE',@NewJSON,@OldJSON


    end;  
  
    update [RH].[tblEmpleados]  
    set UMF = @UMF  
    where IDEmpleado = @IDEmpleado     
  
    --exec [Bk].[spIEmpleadoActualizado]  
    -- @IDEmpleado = @IDEmpleado  
    --,@Tabla = '[RH].[TblSaludEmpleado]'  
    --,@IDUsuario = @IDUsuario  
  
    exec [RH].[spBuscarSaludEmpleado] @IDSaludEmpleado = @IDSaludEmpleado  
    exec [RH].[spIUBrigadaEmpleado] @IDEmpleado,@Brigadas, @IDUsuario = @IDUsuario  
  
    --exec [Bk].[spIEmpleadoActualizado]  
    -- @IDEmpleado = @IDEmpleado  
    --,@Tabla = '[RH].[tblBrigadasEmpleado]'  
    --,@IDUsuario = @IDUsuario  
  
 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
