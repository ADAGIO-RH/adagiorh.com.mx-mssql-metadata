USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TblEmpleadoActualizado](
	[IDEmpleadoActualizado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Tabla] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_BkTblEmpleadoActualizado_IDEmpleadoActualizado] PRIMARY KEY CLUSTERED 
(
	[IDEmpleadoActualizado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bk].[TblEmpleadoActualizado] ADD  CONSTRAINT [D_BkTblEmpleadoActualizado_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Bk].[TblEmpleadoActualizado]  WITH CHECK ADD  CONSTRAINT [Fk_BkTblEmpleadoActualizado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Bk].[TblEmpleadoActualizado] CHECK CONSTRAINT [Fk_BkTblEmpleadoActualizado_IDEmpleado]
GO
ALTER TABLE [Bk].[TblEmpleadoActualizado]  WITH CHECK ADD  CONSTRAINT [Fk_BkTblEmpleadoActualizado_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Bk].[TblEmpleadoActualizado] CHECK CONSTRAINT [Fk_BkTblEmpleadoActualizado_IDUsuario]
GO
