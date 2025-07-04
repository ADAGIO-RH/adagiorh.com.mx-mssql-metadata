USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblCatLockers](
	[IDLocker] [int] IDENTITY(1,1) NOT NULL,
	[IDCaseta] [int] NOT NULL,
	[Codigo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Disponible] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_ResguardoTblCatLockers_IDLocker] PRIMARY KEY CLUSTERED 
(
	[IDLocker] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblCatLockers] ADD  CONSTRAINT [D_ResguardoTblCatCatLockers_Disponible]  DEFAULT ((1)) FOR [Disponible]
GO
ALTER TABLE [Resguardo].[tblCatLockers] ADD  CONSTRAINT [D_ResguardoTblCatCatLockers_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [Resguardo].[tblCatLockers] ADD  CONSTRAINT [D_ResguardoTblCatCatLockers_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Resguardo].[tblCatLockers]  WITH CHECK ADD  CONSTRAINT [Fk_ResguardoTblCatCatLockersResguardoTblCatCasetas_IDCaseta] FOREIGN KEY([IDCaseta])
REFERENCES [Resguardo].[tblCatCasetas] ([IDCaseta])
ON DELETE CASCADE
GO
ALTER TABLE [Resguardo].[tblCatLockers] CHECK CONSTRAINT [Fk_ResguardoTblCatCatLockersResguardoTblCatCasetas_IDCaseta]
GO
