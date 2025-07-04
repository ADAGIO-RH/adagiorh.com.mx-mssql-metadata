USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auditoria].[tblAuditoria](
	[IDAuditoria] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Tabla] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Procedimiento] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Accion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NewData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OldData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[InformacionExtra] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblAuditoria_IDAuditoria] PRIMARY KEY CLUSTERED 
(
	[IDAuditoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Auditoria].[tblAuditoria] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [Auditoria].[tblAuditoria]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_Auditoria_tblAuditoria_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Auditoria].[tblAuditoria] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_Auditoria_tblAuditoria_IDUsuario]
GO
