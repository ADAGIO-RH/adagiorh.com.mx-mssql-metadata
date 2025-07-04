USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida el acceso al sistema adagioRH
** Autor			: José Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2017-08-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-09-20			Aneudy Abreu	Se cambió la forma de validar el acceso para agregar la llamada 
									del SP  [Seguridad].[spBuscarUsuario]
2021-02-05			Aneudy Abreu	Se agregó una validación para que los colaboradores que no estén 
									vigentes no puedan ingresar al sistema.
2024-07-08          Jose Vargas     Se agrega validaciones relacionada con la rama `SeguridadPasword`
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spLogin](
	@Usuario Varchar(50)
	,@Password Varchar(50)
	,@IDIdioma Varchar(5) = 'es'
	,@ZonaHoraria varchar(70)
	,@Browser varchar(max)
	,@GeoLocation varchar(max)
	
)
AS
BEGIN
	declare 
		@IDUsuario int = null,
		@IDUsuarioo int = null,
		@Message varchar(max),
		@CustomMessage varchar(max) = 'Es probable que el colaborador no se encuentre vigente.',
		@LoginCorrecto bit,
		@Intentos int,  --= (select Valor from App.tblConfiguracionesGenerales where IDConfiguracion = 'NumeroIntentosLogin'),	-- viene del general config
		@Minutos int, --= (select Valor from App.tblConfiguracionesGenerales where IDConfiguracion = 'RangoIntentosLogin'),	-- viene del general config
		@FechaHora datetime = getdate(),
		@Key varchar(255) = NEWID(),
		@bloquear_x_intentos_login varchar(20)
	;-- var resolvedOptions = Intl.DateTimeFormat().resolvedOptions(); zona horaria local con JS
    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
    
    declare @jsonstring NVARCHAR(max)
    select @jsonstring=Valor from app.tblConfiguracionesGenerales  where IDConfiguracion='SeguridadPasswordLogin'    
    declare @tempConfiguracion as table (
        clave NVARCHAR(MAX),
        valor NVARCHAR(MAX)
    );
    INSERT INTO @tempConfiguracion (clave, valor)
    SELECT [key], value FROM OPENJSON(@jsonstring);
    
    set @Intentos= isnull((select cast(valor as int) from @tempConfiguracion where clave='numero_intentos_login'),3)
    set @Minutos = isnull((select cast(valor as int) from @tempConfiguracion where clave='rango_intentos_login'), 5)
    set @bloquear_x_intentos_login = isnull((select valor from @tempConfiguracion where clave='bloquear_x_intentos_login'), 'false')

    Select top 1 @IDUsuario = u.IDUsuario
    from Seguridad.tblUsuarios u with(nolock)
        left join RH.tblEmpleadosMaster e on e.IDEmpleado = u.IDEmpleado
    Where (u.Cuenta = @Usuario or u.Email=@Usuario) 
        and u.Password = @Password 
        and isnull(u.Activo,0) = 1 
        and (isnull(u.IDEmpleado,0) = 0 or isnull(e.Vigente, 0) = 1)

    Select top 1 @IDUsuarioo = u.IDUsuario
        from Seguridad.tblUsuarios u with(nolock)
        left join RH.tblEmpleadosMaster e on e.IDEmpleado = u.IDEmpleado
        Where (u.Cuenta = @Usuario or u.Email=@Usuario)
        and isnull(u.Activo,0) = 1 
        and (isnull(u.IDEmpleado,0) = 0 or isnull(e.Vigente, 0) = 1)

    if exists(select top 1 1 from Seguridad.tblUsuarios where IDUsuario = @IDUsuarioo and Bloqueado = 1)
    begin
        raiserror('Tu usuario fue bloqueado por superar el numero de intentos fallidos permitidos, te hemos enviado un correo para que actualices tu contraseña',16,1);
        return
    end

	
	IF (@IDUsuario is not null)
	BEGIN
		exec [Seguridad].[spBuscarUsuario] @IDUsuario=@IDUsuario
		-- aqui va el sp que agrega un registro de loginCorrecto a la tabla [Seguridad].[tblHistorialLoginUsuario], el sp tambien actualiza el campo Bloqueado en Seguridad.tblUsuarios
		exec [Seguridad].[spIHistorialLoginUsuario] @IDUsuario=@IDUsuario, @ZonaHoraria=@ZonaHoraria, @Browser=@Browser, @GeoLocation=@GeoLocation, @FechaHora=@FechaHora, @LoginCorrecto=1
	END
	ELSE
	BEGIN
		exec [Seguridad].[spIHistorialLoginUsuario] @IDUsuario=@IDUsuarioo, @ZonaHoraria=@ZonaHoraria, @Browser=@Browser, @GeoLocation=@GeoLocation, @FechaHora=@FechaHora, @LoginCorrecto=0
		select top 1 @Message = e.Descripcion    
		from App.tblCatErrores E with (nolock)    
		where (e.Codigo = '0000001') and ((e.IDIdioma like @IDIdioma+'%') or (@IDIdioma is null))    
		-- aqui va el sp que agrega un registro de loginFail a la tabla [Seguridad].[tblHistorialLoginUsuario], el sp tambien actualiza el campo Bloqueado en Seguridad.tblUsuarios
		
		--set @Message = coalesce(@Message,'') +' '+coalesce(@CustomMessage,'');    
		raiserror(@Message,16,1);    
		--exec [App].[spObtenerError] null,'0000001', 'Es probable que el colaborador no se encuentre vigente.'
		-- [INotificacionActivarCuenta], [spActivarCuentaUsuario], [spActivarCuenta], [spBuscarActivationKey]
	END

	IF OBJECT_ID('tempdb..#tempUsuario') IS NOT NULL DROP TABLE #tempUsuario;

    
    select top (@Intentos) *--, DATEDIFF(MINUTE, FechaHora, getdate()) as MM 
    into #tempUsuario
    from Seguridad.tblHistorialLoginUsuario
    where DATEDIFF(MINUTE, FechaHora, getdate()) <= @minutos
    and IDUsuario = @IDUsuarioo
    order by FechaHora desc
    
	if(isnull(@bloquear_x_intentos_login,'false') = 'true')
	BEGIN
	
		if not exists(select top 1 1 from #tempUsuario where LoginCorrecto = 1) and (select COUNT(*) from #tempUsuario) = @Intentos
		begin
              Select @OldJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE  IDUsuario = @IDUsuarioo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

			update Seguridad.tblUsuarios
			set Bloqueado = 1
			where IDUsuario = @IDUsuarioo
            
            Select @NewJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuarioo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	EXEC [Auditoria].[spIAuditoria] @IDUsuarioo,'[Seguridad].[tblUsuarios]','[Seguridad].[spLogin]','UPDATE',@NewJSON,@OldJSON


			--crea key
			exec [Seguridad].[spBuscarActivationKey] @key=@Key, @crear=1, @IDUsuario=@IDUsuarioo
			-- Enviar notificación
			exec [App].[INotificacionActivarCuenta]
				@IDTipoNotificacion='ActivarCuenta',
				@IDUsuario=@IDUsuarioo,
				@key = @key
			-------
			return 
		end 
	END
END
GO
